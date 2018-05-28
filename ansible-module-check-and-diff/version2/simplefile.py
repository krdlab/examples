import os
from tempfile import gettempdir
from ansible.module_utils.basic import AnsibleModule

class BasicFile(object):
    def __init__(self, path):
        self.path = path

    def exists(self):
        return os.path.exists(self.path)

    def touch(self):
        pass

    def remove(self):
        pass

class CheckModeFile(BasicFile):
    def __init__(self, path):
        super(CheckModeFile, self).__init__(path)

    def touch(self):
        return not self.exists()

    def remove(self):
        return self.exists()

class File(BasicFile):
    def __init__(self, path):
        super(File, self).__init__(path)

    def touch(self):
        with open(self.path, 'a'):
            os.utime(self.path, None)

    def remove(self):
        if self.exists():
            os.remove(self.path)
            return True
        else:
            return False

class SimpleFileModule(object):
    def __init__(self, expected, check_mode):
        self.expected = expected
        self.check_mode = check_mode
        self.file = self.__file(expected['path'])

    def __file(self, path):
        if self.check_mode:
            return CheckModeFile(path)
        else:
            return File(path)

    def ensure(self):
        if self.expected['state'] == 'present':
            return self.__ensure_present()
        else:
            return self.__ensure_absent()

    def __ensure_present(self):
        if self.file.exists():
            return (False, self.expected)
        else:
            self.file.touch()
            return (True, self.expected)

    def __ensure_absent(self):
        return (self.file.remove(), self.expected)

def main():
    module = AnsibleModule(
        argument_spec=dict(
            path=dict(required=True, type='path'),
            state=dict(choices=['present', 'absent'], default=None)
        ),
        supports_check_mode=True
    )

    simplefile = SimpleFileModule(
        expected=dict(
            path=module.params['path'],
            state=module.params['state']
        ),
        check_mode=module.check_mode
    )

    changed, params = simplefile.ensure()
    module.exit_json(changed=changed, simplefile=params)

if __name__ == '__main__':
    main()
