**reStructuredText cheatsheet**
----

|
|

`home <https://github.com/risebeyondio/io>`_

|
|

.. comment --> depth describes headings level inclusion
.. contents:: contents
   :depth: 10

|
|

Title
-----


H1
==

****
H2
****

H3
####

H4
****

H4B
****

H3B
####


External hyperlinks, like Python_.

.. _Python: http://www.python.org/ 

haha_

.. _haha: https://github.com/szczepanski/fr/blob/master/a2.rst

.. code:: python

  def my_function():
      "just a test"
      print(8/2)


.. code:: html
    <h1>code block example</h1>


what
  Definition lists associate a term with
  a definition.


manual grid table

+------------+------------+-----------+
| Header 1   | Header 2   | Header 3  |
+============+============+===========+
| body row 1 | column 2   | column 3  |
+------------+------------+-----------+
| body row 2 | Cells may span columns.|
+------------+------------+-----------+
| body row 3 | Cells may  | - Cells   |
+------------+ span rows. | - contain |
| body row 4 |            | - blocks. |
+------------+------------+-----------+



manual simple table


=====  =====  ======
   Inputs     Output
------------  ------
  A      B    A or B
=====  =====  ======
False  False  False
True   False  True
False  True   True
True   True   True
=====  =====  ======
  
``inline code``


automated table example


.. table:: auto widths
   :widths: auto
   :align: center
   
   =====  =====
     A    not A
   =====  =====
   False  True
   True   False
   =====  =====


automated csv table

.. csv-table:: CSV
   :header: "Treat", "Quantity", "Description"
   :align: center
   :widths: auto
   
   "Albatross", 2.99, "On a stick!"
   "Crunchy Frog", 1.49, "If we took the bones out, it wouldn't be
   crunchy, now would it?"
   "Gannet Ripple", 1.99, "On a stick!"
   
   
automated list table
   
.. list-table:: list
   :align: right
   :widths: auto
   :header-rows: 2

   * - Treat
     - Quantity
     - Description
   * - a
     - b
     - c
   * - Albatross
     - 2.99
     - On a stick!
   * - Crunchy Frog
     - 1.49
     - If we took the bones out, it wouldn't be
       crunchy, now would it?
   * - Gannet Ripple
     - 1.99
     - On a stick!
     
Block quotes

   Indented paragraphs,
   
   Indented paragraphs,

      and they may nest. 
      
     


