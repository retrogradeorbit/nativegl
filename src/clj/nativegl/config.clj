(ns nativegl.config
  (:require [clojure.java.io :as io]))

(set! *warn-on-reflection* true)

(def libs-set ["libnativegl.dylib" "libnativegl.so" "nativegl.dll"])

(defn path-split
  "give a full path filename, return a tuple of
  [path basename]

  eg \"blog/posts/1/main.yml\" -> [\"blog/posts/1\" \"main.yml\"]
  "
  [filename]
  (let [file (io/file filename)]
    [(.getParent file) (.getName file)]))

(defn path-join
  "given multiple file path parts, join them all together with the
  file separator"
  [& parts]
  (.getPath ^java.io.File (apply io/file parts)))

(defn setup
  "Copy any of the bundled dynamic libs from resources to the
  run time lib directory"
  [libs-dir]
  (doseq [filename libs-set]
    (when-let [file (io/resource filename)]
      (let [[_ name] (path-split (.getFile file))
            dest-path (path-join libs-dir name)
            resource-size (with-open [out (java.io.ByteArrayOutputStream.)]
                            (io/copy (io/input-stream file) out)
                            (count (.toByteArray out)))]
        ;; writing to a library while running its code can result in segfault
        ;; only write if filesize is different or it doesnt exist
        (when (or (not (.exists (io/file dest-path)))
                  (not= (.length (io/file dest-path)) resource-size))
          (println "writing:" dest-path)
          (io/copy (io/input-stream file) (io/file dest-path)))))))

(defn get-libs-dir []
  (let [home-dir (System/getenv "HOME")
        config-dir (path-join home-dir ".nativegl")
        libs-dir (path-join config-dir "libs")]
    libs-dir))

(defn init! []
  (let [native-image?
        (and (= "Substrate VM" (System/getProperty "java.vm.name"))
             (= "runtime" (System/getProperty "org.graalvm.nativeimage.imagecode")))
        libs-dir (get-libs-dir)]
    (.mkdirs (io/as-file libs-dir))
    (setup libs-dir)
    (when native-image?
      ;; most JVM implementations: this property needs to be set on launch
      ;; but graalvm allows us to dynamically change it
      (println "setting java.library.path:" libs-dir)
      (System/setProperty "java.library.path" libs-dir))))
