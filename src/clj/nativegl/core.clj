(ns nativegl.core
  (:require [nativegl.config :as config])
  (:gen-class))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "init!...")
  (config/init!)
  ;; (println "loadLibrary SDL2...")
  ;; (clojure.lang.RT/loadLibrary "SDL2")
  (println "loadLibrary nativegl...")
  (clojure.lang.RT/loadLibrary "nativegl")
  (println "Hello, World!")
  (println "jni says:" (NativeGL/is_a_tty))
  (println "SDL_Init()...")
  (println "returns:" (NativeGL/init))
  (println "SDL_CreateWindow...")
  (let [window (NativeGL/create_window (.getBytes "NativeGL" "UTF-8") 0 0 200 200 0)]
    (println "window:" window)
    (Thread/sleep 3000)
    (println "SDL_DestroyWindow()")
    (NativeGL/destroy_window window)
    )
  (println "SDL_Quit()...")
  (println "returns:" (NativeGL/quit))
  )
