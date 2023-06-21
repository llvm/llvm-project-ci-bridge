from __future__ import absolute_import
import os

import lit.Test
import lit.util


class TestFormat(object):
    pass


###


class FileBasedTest(TestFormat):
    def getTestsInDirectory(self, testSuite, path_in_suite, litConfig, localConfig):
        source_path = testSuite.getSourcePath(path_in_suite)
        for filename in os.listdir(source_path):
            # Ignore dot files and excluded tests.
            if filename.startswith(".") or filename in localConfig.excludes:
                continue

            filepath = os.path.join(source_path, filename)
            if not os.path.isdir(filepath):
                base, ext = os.path.splitext(filename)
                if ext in localConfig.suffixes:
                    yield lit.Test.Test(
                        testSuite, path_in_suite + (filename,), localConfig
                    )


###

# Check exit code of a simple executable with no input
class ExecutableTest(FileBasedTest):
    def execute(self, test, litConfig):
        if test.config.unsupported:
            return lit.Test.UNSUPPORTED

        out, err, exitCode = lit.util.executeCommand(test.getSourcePath())

        if not exitCode:
            return lit.Test.PASS, ""

        return lit.Test.FAIL, out + err
