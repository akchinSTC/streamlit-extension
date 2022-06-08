#
# Copyright 2022 Elyra Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
.PHONY: clean clean-test clean-pyc clean-build help
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

WHEEL_FILES:=$(shell find . -type f ! -path "./build/*" ! -path "./etc/*" ! -path "./docs/*" ! -path "./.git/*" ! -path "./.idea/*" ! -path "./dist/*" ! -path "./.image-*" )
WHEEL_FILE := dist/streamlit_extension*.whl
TAR_FILE := dist/streamlit_extension*.tar.gz
TAG := dev

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test:
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

release: dist ## package and upload a release
	twine upload dist/*

$(WHEEL_FILE): $(WHEEL_FILES)
	python setup.py bdist_wheel

bdist:
	@make $(WHEEL_FILE)

sdist:
	python setup.py sdist

dist: clean lint ## builds source and wheel package
	@make sdist
	@make bdist
	ls -l dist

install: clean dist ## install the package to the active Python's site-packages
	pip install --upgrade dist/*.whl