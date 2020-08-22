# -*- coding: utf-8 -*-
"""
    pygments.styles.algforopt
    ~~~~~~~~~~~~~~~~~~~~~~~

    :license: MIT
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, Text, \
     Number, Operator, Generic, Whitespace, Punctuation, Other, Literal

class AlgForOptStyle(Style):
    """
    This style is for the Algorithms for Optimization book.
    """

    # pastelMagenta FF48CF
    # pastelPurple 8770FE
    # pastelBlue 1BA1EA
    # pastelSeaGreen 14B57F
    # pastelGreen 3EAA0D
    # pastelOrange C38D09
    # pastelRed F5615C

    background_color = "#f8f8f8"
    default_style = ""

    styles = {
        Whitespace:                "#bbbbbb",
        Comment:                   "italic #0b5075",
        Comment.Preproc:           "noitalic #BC7A00",

        Keyword:                   "bold #1BA1EA",
        Keyword.Pseudo:            "nobold",
        Keyword.Type:              "nobold #1BA1EA",
        Keyword.Other:             "bold #73C6F2",
        Other:                     "bold #73C6F2",


        Operator:                  "#999999",
        Operator.Word:             "bold #AA22FF",


        Name.Builtin:              "#1BA1EA",
        Name.Function:             "#0000FF",
        Name.Class:                "bold #14B57F",
        Name.Namespace:            "bold #0000FF",
        Name.Exception:            "bold #D2413A",
        Name.Variable:             "#19177C",
        Name.Constant:             "#880000",
        Name.Label:                "#A0A000",
        Name.Entity:               "bold #999999",
        Name.Attribute:            "#7D9029",
        Name.Tag:                  "bold #1BA1EA",
        Name.Decorator:            "#FF48CF",

        String:                    "#F5615C",
        String.Doc:                "italic",
        String.Interpol:           "bold #BB6688",
        String.Escape:             "bold #BB6622",
        String.Regex:              "#F5615C",
        String.Symbol:             "#F3453F",
        String.Other:              "#1BA1EA",
        Number:                    "#666666",

        Generic.Heading:           "bold #000080",
        Generic.Subheading:        "bold #800080",
        Generic.Deleted:           "#A00000",
        Generic.Inserted:          "#00A000",
        Generic.Error:             "#FF0000",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold #0F6FA3",
        Generic.Output:            "#888",
        Generic.Traceback:         "#04D",

        Error:                     "border:#FF0000"
    }