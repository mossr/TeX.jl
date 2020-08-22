#!/usr/bin/python

from setuptools import setup, find_packages

setup(
    name='pygments-julia',
    description='Pygments lexers for Julia.',
    long_description=open('README.md').read(),
    keywords='pygments julia lexer',

    packages=find_packages(),
    install_requires=['pygments>=2.2'],

    entry_points='''[pygments.lexers]
                    julia1=pygments_julia:Julia1Lexer
					jlcon1=pygments_julia:Julia1ConsoleLexer
					''',

    classifiers=[
        'Development Status :: 4 - Beta',
        'Environment :: Plugins',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
)
