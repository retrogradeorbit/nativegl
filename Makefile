GRAALVM_HOME = $(HOME)/graalvm-ce-java11-20.1.0
ifneq (,$(findstring java11,$(GRAALVM_HOME)))
	JAVA_VERSION = 11
else
	JAVA_VERSION = 8
endif
VERSION = $(shell cat .meta/VERSION)
UNAME = $(shell uname)

all: build/nativegl

analyse:
	$(GRAALVM_HOME)/bin/java -agentlib:native-image-agent=config-output-dir=config-dir \
		-jar target/uberjar/nativegl-$(VERSION)-standalone.jar

build/nativegl: target/uberjar/nativegl-$(VERSION)-standalone.jar
	-mkdir build
	$(GRAALVM_HOME)/bin/native-image \
		-jar target/uberjar/nativegl-$(VERSION)-standalone.jar \
		-H:Name=build/nativegl \
		-H:+ReportExceptionStackTraces \
		-J-Dclojure.spec.skip-macros=true \
		-J-Dclojure.compiler.direct-linking=true \
		-H:ConfigurationFileDirectories=graal-configs/ \
		--initialize-at-build-time \
		--initialize-at-run-time=com.jcraft.jsch.PortWatcher \
		-H:Log=registerResource: \
		-H:EnableURLProtocols=http,https \
		--enable-all-security-services \
		-H:+JNI \
		--report-unsupported-elements-at-runtime \
		--verbose \
		--allow-incomplete-classpath \
		--no-fallback \
		--no-server \
		"-J-Xmx6500m"
	cp build/nativegl nativegl

JNI_DIR=target/jni
CLASS_DIR=target/default/classes
CLASS_NAME=NativeGL
CLASS_FILE=$(CLASS_DIR)/$(CLASS_NAME).class
JAR_FILE=target/uberjar/nativegl-$(VERSION)-standalone.jar
SOLIB_FILE=$(JNI_DIR)/libnativegl.so
DYLIB_FILE=$(JNI_DIR)/libnativegl.dylib
JAVA_FILE=src/c/NativeGL.java
C_FILE=src/c/NativeGL.c
C_HEADER=$(JNI_DIR)/NativeGL.h
ifndef JAVA_HOME
	JAVA_HOME=$(GRAALVM_HOME)
endif
INCLUDE_DIRS=$(shell find $(JAVA_HOME)/include -type d)
INCLUDE_ARGS=$(INCLUDE_DIRS:%=-I%) -I$(JNI_DIR)

ifeq ($(UNAME),Linux)
	LIB_FILE=$(SOLIB_FILE)
else ifeq ($(UNAME),FreeBSD)
	LIB_FILE=$(SOLIB_FILE)
else ifeq ($(UNAME),Darwin)
	LIB_FILE=$(DYLIB_FILE)
endif

run: $(LIB_FILE) $(JAR_FILE)
	java -Djava.library.path=./ -jar $(JAR_FILE)

jar: $(JAR_FILE)

$(JAR_FILE): $(CLASS_FILE) $(C_HEADER) $(LIB_FILE)
	GRAALVM_HOME_HOME=$(GRAALVM_HOME) lein with-profiles +native-image uberjar

$(CLASS_FILE): $(JAVA_FILE)
	lein javac

header: $(C_HEADER)

$(C_HEADER): $(CLASS_FILE)
	mkdir -p $(JNI_DIR)
ifeq ($(JAVA_VERSION),8)
	javah -o $(C_HEADER) -cp $(CLASS_DIR) $(CLASS_NAME)
else
	javac -h $(JNI_DIR) $(JAVA_FILE)
endif
	@touch $(C_HEADER)

lib: $(LIB_FILE)

$(SOLIB_FILE): $(C_FILE) $(C_HEADER)
	$(CC) $(INCLUDE_ARGS) -shared $(C_FILE) -o $(SOLIB_FILE) -fPIC
	cp $(SOLIB_FILE) ./
	mkdir -p resources
	cp $(SOLIB_FILE) ./resources/

$(DYLIB_FILE):  $(C_FILE) $(C_HEADER)
	$(CC) $(INCLUDE_ARGS) -dynamiclib -undefined suppress -flat_namespace $(C_FILE) -o $(DYLIB_FILE) -fPIC
	cp $(DYLIB_FILE) ./
	mkdir -p resources
	cp $(DYLIB_FILE) ./resources/

clean:
	-rm -rf build target
	lein clean
	-rm src/c/*.o libnativegl.so src/c/NativeGL.h resources/libnativegl.so libnativegl.dynlib resources/libnativegl.dynlib
	-rm -rf $(JNI_DIR)

linux-package:
	-rm -rf build/linux-package
	-mkdir -p build/linux-package
	cp nativegl build/linux-package
	cd build/linux-package && GZIP=-9 tar cvzf ../nativegl-$(VERSION)-linux-amd64.tgz nativegl
	cp target/uberjar/nativegl-$(VERSION)-standalone.jar build/nativegl-$(VERSION)-linux-standalone.jar
	du -sh nativegl build/nativegl-$(VERSION)-linux-amd64.tgz build/nativegl-$(VERSION)-linux-standalone.jar
