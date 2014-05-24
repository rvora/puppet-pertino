Pertino module
=

Pertino client install and configuration module

To use it:

    class { 'pertino':
      username     => 'joe@example.com',
      password     => 'SuperscretPassword'
    } 

To remove a meter change your include to:

    class { 'pertino::delete': }

Author
---

Rajul Vora <rvora@cloudopia.co>

Copyright
---

Pertino 2014

License
---

Apache 2.0


