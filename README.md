# yaml2htmlTables
This is a quick and easy HTML table generator for easy cut and paste of links.
Links can be frormatted into YAML, a resonably easy format to understand with no prior experience.
YAML allows nested trees on information, really its a text based database.

We have skipped CSS/PHP/Javascript to get something thats quick, useable and looks good.

#
Uses YAML as an input

```console
## The # signifies a comment, and is ignored by parsers, but can be read by humans
# This is an example to show how the keys are structured. : denotes a new space essentially and you can see
# below how the structure becomes a tree, i.e. its not flat, but readable.
councilArea : 
  SubCatagoryHeading :
    desc  : ""
    links : 
      CatagoryName:
        web  : "Optional Web adress"
        fb   : "Optional facebook link"
        tw   : "Optional twitter link"
        tel  : "Optional Landline"
        mob  : "Optional Mobile number"
        email: "Optional Email address"
        desc : "Optional description"
```
Validate YAML at [yamllint](http://www.yamllint.com)

See the results at Validate YAML at [www.roslinvillage.com/covid19](https://roslinvillage.com/covid19/)
