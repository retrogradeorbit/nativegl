(defproject nativegl "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies [[org.clojure/clojure "1.10.2-alpha1"]]
  :source-paths ["src/clj"]
  :java-source-paths ["src/c" "src/java"]
  :jvm-opts ["-Djava.library.path=./"]
  :main ^:skip-aot nativegl.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all
                       :jvm-opts ["-Dclojure.compiler.direct-linking=true"
                                  "-Dclojure.spec.skip-macros=true"
                                  "-Djava.library.path=./"
                                  ]}
             :native-image {}})
