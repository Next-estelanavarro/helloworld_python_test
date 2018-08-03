# Make shell
SHELL := /bin/bash

# Execution context
USING_DOCKER:= false

# Project prefix
PROJECT := sdmt

# AWS Region to deploy Lambdas
REGION := eu-west-1

# Enviroment
ENV := test

# AWS profile as listed in credentials used to deploy and update lambdas
PROFILE :=

# Project DIR
ifeq ($(USING_DOCKER),true)
    ROOT_DIR:=/home/jenkins
else
    ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
endif

# Directory that holds lambda source code
SOURCE_DIR = $(ROOT_DIR)/src

# Directory that holds lambda source code
CONFIG_DIR = $(ROOT_DIR)/config

# Directory that holds lambda source code
REPORT_DIR = $(ROOT_DIR)/reports

# Directory for storing builds
BUILD_DIR = $(ROOT_DIR)/build

# Directory for storing coverage reports
COVERAGE_REPORTS_DIR = $(REPORT_DIR)/coverage

# Directory for storing qa reports
QA_REPORTS_DIR = $(REPORT_DIR)/qa

# Directory that holds lambda tests
TESTS_DIR = test

# Apply targets on this function
LAMBDA_FUNCTION :=

# Known Functions in source Dir
LAMBDA_FUNCTION_NAMES := ${shell cd $(SOURCE_DIR) && find -maxdepth 1 -mindepth 1 -type d -exec basename {} \;}


.PHONY: clean all

all:
		@for f in $(LAMBDA_FUNCTION_NAMES); do \
			make build-lambda LAMBDA_FUNCTION=$$f; \
		done
		@$(DONE)

clean:
		rm -rf $(REPORT_DIR)
		rm -rf $(BUILD_DIR)
		rm -rf $(ROOT_DIR)/**/*.html
		rm -rf $(ROOT_DIR)/**/libs/
		rm -rf $(SOURCE_DIR)/**/*-dev
		rm -rf $(SOURCE_DIR)/**/*-pre
		rm -rf rm -rf $(SOURCE_DIR)/*/.coverage
		@$(DONE)

test: _check-params
		mkdir -p $(COVERAGE_REPORTS_DIR); \
		pushd $(SOURCE_DIR)/$(LAMBDA_FUNCTION); \
		if [ -d "$(TESTS_DIR)" ] ; then \
			virtualenv $(LAMBDA_FUNCTION)-$(ENV)-tests && \
			. $(LAMBDA_FUNCTION)-$(ENV)-tests/bin/activate && \
			pip install --force-reinstall coverage && \
			pip install --force-reinstall -r $(TESTS_DIR)/requirements.txt && \
			python -m unittest discover tests -v && exit 0 || exit $?;\
			coverage run -m unittest discover tests -v && \
			coverage html --omit="*/test*,*/lib/*" -d $(COVERAGE_REPORTS_DIR)/$(LAMBDA_FUNCTION)|| exit 0 && \
			deactivate; \
			rm -rf $(LAMBDA_FUNCTION)-$(ENV)-tests ;\
		fi ;\
		popd
		@$(DONE)

qa: _check-params
		mkdir -p $(QA_REPORTS_DIR);  \
		pushd $(SOURCE_DIR)/$(LAMBDA_FUNCTION); \
		virtualenv $(LAMBDA_FUNCTION)-$(ENV)-qa; \
		. $(LAMBDA_FUNCTION)-$(ENV)-qa/bin/activate; \
		pip install --force-reinstall pylint; \
		pylint *.py ; \
		deactivate ;\
		popd 
		@$(DONE)

build-lambda: _check-env _check-params
		for f in `ls $(CONFIG_DIR)/$(LAMBDA_FUNCTION)/*$(ENV).py` ; do \
			SUFFIX=`(basename $$f | cut -d. -f1)`;\
			OUTPUT=$(LAMBDA_FUNCTION)-$$SUFFIX ; \
			pushd $(SOURCE_DIR)/$(LAMBDA_FUNCTION); \
			virtualenv $(LAMBDA_FUNCTION)-$(ENV); \
			. $(LAMBDA_FUNCTION)-$(ENV)/bin/activate; \
			pip install --force-reinstall -r requirements.txt -t libs ;  \
			cp $$f config.py ;\
			zip -r $$OUTPUT.zip requirements.txt *.py resources/ ; \
			[ -d "libs" ] && cd libs/ && zip -r ../$$OUTPUT.zip * && cd ..; \
			deactivate; \
			rm -rf $(SOURCE_DIR)/$(LAMBDA_FUNCTION)/$(LAMBDA_FUNCTION)-$(ENV); \
			rm -rf $(SOURCE_DIR)/$(LAMBDA_FUNCTION)/libs; \
			popd; \
			mkdir -p $(BUILD_DIR); \
			mv $(SOURCE_DIR)/$(LAMBDA_FUNCTION)/$$OUTPUT.zip $(BUILD_DIR)/$$OUTPUT.zip ; \
		done
		@$(DONE)

upload-lambda: _check-env

		if [ -d "$(BUILD_DIR)" ] ; then \
			aws $(if ${PROFILE},--profile ${PROFILE},) s3 cp $(BUILD_DIR)/ s3://sd-materialtracking-infra-$(ENV)/lambdas/ --recursive; \
		fi
		@$(DONE)

update-lambda:
		if [ -d "$(BUILD_DIR)" ]; then \
			for f in `ls $(BUILD_DIR)`; do \
				functioname=`basename $$f .zip` ;\
				aws $(if ${PROFILE},--profile ${PROFILE},) lambda update-function-code \
					--function-name $(PROJECT)-$$functioname \
					--zip-file fileb://$(BUILD_DIR)/$$f \
					--publish \
					--region $(REGION); \
			done ;\
		fi
		@$(DONE)

_check-env:
ifndef ENV
	@echo "You must provide a ENV variable";
	@echo "Use ENV=dev|pre|pro";
	@false;
endif

_check-params:
ifndef PROJECT
	@echo "You must provide a PROJECT variable";
	@false;
endif
ifndef LAMBDA_FUNCTION
	@echo "You must provide a LAMBDA_FUNCTION variable";
	@echo "Select a valid function: altas-mantenimientos-preprocessor|signals-launcher|titan-processor
	@false;
endif

