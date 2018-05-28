import os
from tempfile import gettempdir
from ansible.module_utils.basic import AnsibleModule

class File:
    def __init__(self, path):
        self.path = path

    def exists(self):
        return os.path.exists(self.path)

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
    def __init__(self, expected):
        self.expected = expected
        self.file = File(expected['path'])

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
        )
    )

    simplefile = SimpleFileModule(
        expected=dict(
            path=module.params['path'],
            state=module.params['state']
        )
    )

    changed, params = simplefile.ensure()
    module.exit_json(changed=changed, simplefile=params)

if __name__ == '__main__':
    main()
