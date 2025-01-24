Reference: `https://docs.python.org/3/tutorial/venv.html`

1. Create new virtual environment (directory foo-env will be created)
```
python3 -m venv foo-env
```

2. Start up venv
```
source foo-env/bin/activate
```

3. Manage packages using pip:
```
python -m pip install <package>
python -m pip install <package>==2.5.0
python -m pip uninstall <package>

4. (Optional) Create a requirements.txt file
```
pip freeze > requirements.txt

# To install packages using this file:
python3 -m pip install -r requirements.txt
```

5. Exit when done
```
deactivate
```


## Debug

```
python -m pip show <package>
python -m pip list
```

