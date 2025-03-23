from setuptools import setup, find_packages

setup(
    name='holoclean',
    version='0.1',
    description='HoloClean: A statistical inference engine for data cleaning',
    packages=find_packages(where='.', include=['holoclean', 'holoclean.*']),
    package_dir={'holoclean': 'holoclean'},
    install_requires=[
        'enum34==1.1.6',
        'gensim==3.7.1',
        'numpy==1.16.1',
        'pandas==0.24.1',
        'psycopg2-binary==2.7.7',
        'pyitlib==0.2.0',
        'pytest-xdist==1.26.1',
        'python-Levenshtein==0.12.0',
        'scikit-learn==0.20.0',
        'scipy==1.2.1',
        'sqlalchemy==1.2.17',
        'torch==1.1.0',
        'tqdm==4.31.0',
        'smart-open==6.0.0'
    ],
    python_requires='==3.6.*',
)
