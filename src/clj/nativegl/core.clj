(ns nativegl.core
  (:require [nativegl.config :as config])
  (:gen-class))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "init!...")
  (config/init!)
  (println "loadLibrary...")
  (clojure.lang.RT/loadLibrary "nativegl")
  (println "Hello, World!")
  (println "jni says:" (NativeGL/is_a_tty))
  )
