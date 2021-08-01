# Cruise :rocket:

Testing automatic deployment of ml models as rest apis to heroku using tensorflow serving.

# Try it out.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/JesuFemi-O/Cruise)

# How to test it

here's a simple script you can run on your PC:

```
import requests
import json
import numpy as np
from tensorflow.keras.datasets.mnist import load_data


#load MNIST dataset
(_, _), (x_test, y_test) = load_data()

# reshape data to have a single channel
x_test = x_test.reshape((x_test.shape[0], x_test.shape[1], x_test.shape[2], 1))

# normalize pixel values
x_test = x_test.astype('float32') / 255.0


test_img = x_test[0]

YOUR_APP_NAME = "the-name-of-your-heroku-app"
url = f'https://{YOUR_APP_NAME}.herokuapp.com/v1/models/img_classifier:predict'


def make_prediction(instances, many=False):
    if not many:
        data = json.dumps({"signature_name": "serving_default", "instances": [instances.tolist()]})
    else:
        data = json.dumps({"signature_name": "serving_default", "instances": instances.tolist()})
    headers = {"content-type": "application/json"}
    json_response = requests.post(url, data=data, headers=headers)
    predictions = json.loads(json_response.text)['predictions']
    return predictions


for p in make_prediction(test_img):
    print(np.argmax(p))
```

# TO DO:

while the project is still a bit limited. the end goal is to allow you effortlessly deploy your Tensorflow models to heroku and test it easily. to make that possible the plan is to:

- [x] allow users deploy to heroku with the click of a button

- [ ] allow users to provide url to a public bucket with their saved models that can be used

- [ ] introduce swagger UI to make it easy to test and interact with models

# Current state of the project

The project currently uses a model built with MNIST digits dataset as a working proof of concept to show that it is possible to actually deploy with just the click of a button. for more background on tensorflow servning checkout:

- [Documentation](https://www.tensorflow.org/tfx/guide/serving)
- A [Tutorial](https://neptune.ai/blog/how-to-serve-machine-learning-models-with-tensorflow-serving-and-docker) on TF-Serving with Docker
