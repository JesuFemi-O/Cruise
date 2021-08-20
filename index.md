# Easy Model Serving with Cruise

After putting a lot of time and effort in gathering data, cleaning it and building models it would be great if you didn't have to worry deploying the models or even wait for someone else to deploy it for you. Cruise is a tool that helps you to quickly share your tensorflow models as rest apis so that other people can easily test and use it without worrying about common deal breakers like installing tenorflow on their own systems or even knowing how to use tensorflow to load a saved model.

Cruise is the ultimate experimentation tool for data scientists and hobbyists working in fast paced environments or across teams. Cruise helps you deploy your tensorflow models with little to zero knowledge on deployments allowing you focus on just building amazing models. All you need to do is click a button, provide information about your model and you will have a working url you can use in no time!

# How it works

## Step 1: Build your Tensorflow model:

<br/>

We will use an MNIST Digits dataset as our example model here.

```python

import matplotlib.pyplot as plt
import time
from numpy import asarray
from numpy import unique
from numpy import argmax
from tensorflow.keras.datasets.mnist import load_data
from tensorflow.keras import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Conv2D
from tensorflow.keras.layers import MaxPool2D
from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dropout

#load MNIST dataset
(x_train, y_train), (x_test, y_test) = load_data()
print(f'Train: X={x_train.shape}, y={y_train.shape}')
print(f'Test: X={x_test.shape}, y={y_test.shape}')

# reshape data to have a single channel
x_train = x_train.reshape((x_train.shape[0], x_train.shape[1], x_train.shape[2], 1))
x_test = x_test.reshape((x_test.shape[0], x_test.shape[1], x_test.shape[2], 1))

# normalize pixel values
x_train = x_train.astype('float32') / 255.0
x_test = x_test.astype('float32') / 255.0

# set input image shape
input_shape = x_train.shape[1:]

# set number of classes
n_classes = len(unique(y_train))

# define model
model = Sequential()
model.add(Conv2D(64, (3,3), activation='relu', input_shape=input_shape))
model.add(MaxPool2D((2, 2)))
model.add(Conv2D(32, (3,3), activation='relu'))
model.add(MaxPool2D((2, 2)))
model.add(Flatten())
model.add(Dense(50, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(n_classes, activation='softmax'))

# define loss and optimizer
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# fit the model
model.fit(x_train, y_train, epochs=10, batch_size=128, verbose=1)

# evaluate the model
loss, acc = model.evaluate(x_test, y_test, verbose=0)
print('Accuracy: %.3f' % acc)
```

<br/>

## Step 2: Save the model:

<br/>

```python
#save model
ts = int(time.time())
file_path = f"tf-models/img_classifier/{ts}/"
model.save(filepath=file_path, save_format='tf')
```

take note of the following:

1. the file path defines a base folder (tf-models) which you can give any name except models because the tf-server has a defualt folder called models and can lead to a conflict when cruise attempts to deploy your model for you.

2. img_classifier is the name of the model we are building. the folder ideally holds 1 to many versions of our model

3. we use a timestamp value to create a folder that stores the actual files needed to load our model. we can also use numbers.

4. if we ran our code again, it would save a new model in the img_classifier folder using a new timestamp which means we can have multiple versions of our models and easily use anyone which is a great way to track the different models you are building while experimenting.

<br/>

## Step 3: Create a model configuration file

<br/>

The model config file is what tensorflow serving will use to load your model

- navigate to the base folder holding the model (tf-models) and create a file named models.conf

- add the followng into the file:

```
model_config_list: {
    config: {
        name: "img_classifier",
        base_path: "/tf-models/img_classifier",
        model_platform: "tensorflow",
        model_version_policy: {all: {}}
    }
}
```

we added in information about our model and where it can be located. the name of the model should be the same as the name of the folder holding the model versions (the folders whose names are timestamps). recall that we called ours img_classifier

the base path describes the absolute path to our model from it's top-most directory to the folder holding the model versions.

<br/>

## Step 4: zip your model as a tar.gz file

<br/>

```python
import tarfile
import os

def tar_folder(output_filename: str, source_dir: str):
    with tarfile.open(output_filename, "w:gz") as tar:
        tar.add(source_dir, arcname=os.path.basename(source_dir))

OUT_FILE = 'tf-models.tar.gz'

SOURCE_FILE = "tf-models"

tar_folder(output_filename=OUT_FILE, source_dir=SOURCE_FILE)

```

<br/>

## Step 5: Upload zipped file to AWS

in order to deploy with cruise, you have to upload the zipped file to a public aws bucket to enable cruise download and use your model

NB:

if you're not familliar with AWS S3 buckets policies, here's an example of a policy that makes your S3 bucket publicly acessible:

After creating an s3 bucket, click on it and navigate to it's permissions tab. scroll down to bucket policy section and

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowReadFromBucket",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
    ]
}
```

simply replace 'YOUR-BUCKET-NAME' with the name of the bucket you created

<br/>

## Step 6: Use Cruise :rocket:

<br/>

- open the [Cruise Repo](https://github.com/JesuFemi-O/Cruise) and click on the deploy button!

- provide the s3 url for the model

- provide the model base path (the name before the tar.gz extension in the s3 bucket url)

- provide the models configuration file name (e.g. models.conf)

- click on deploy :rocket:

<br/>

# Test your model

you can easily check if your model is available by navigating to:

```
https://YOUR-APP-NAME.herokuapp.com/v1/models/YOUR-MODEL-NAME
```

from our example, if we called our heroku app cruise-demo, our model can be found at:

```
https://cruise-demo.herokuapp.com/v1/models/img_classifier
```

<br/>

# Advanced Usage

<br/>

## Serving multiple versions of a single model with Cruise

multiple version serving is as simple as saving new model versions in your model folder.

if tensorflow serving discovers multiple models in your model server, it will by defualt call the latest model. To serve a specific model you have to refer to it using versions.

<br/>

## Simple Example

if we have two versions of our img_classifier, 1 and 2 then this implies that in our img_classifier folder there will be 2 sub folders called 1 and 2 (we used timestamps in our examples above but we can also use simple integers)

to access model version 1:

```
https://YOUR-APP-NAME.herokuapp.com/v1/models/YOUR-MODEL-NAME/versions/1
```

you simply replace the version number to access another version of the model on your server if it exists.

<br/>

## Serving multiple (Different) models with cruise

Cruise can easily be used to deploy multiple models with multiiple versions. to do this:

- save a new tensorflow model in your models base path (from our example we called it tf-models)

- add a new config to your config file.

<br/>

## Simple Example

if we decied to build a new model called zoonet, wile saving the model we would want to point it to our basepath:

```python
#save model
ts = int(time.time())
file_path = f"tf-models/zoonet/{ts}/"
model.save(filepath=file_path, save_format='tf')
```

we have to also update our models.conf file:

```
model_config_list: {
    config: {
        name: "img_classifier",
        base_path: "/tf-models/img_classifier",
        model_platform: "tensorflow",
        model_version_policy: {all: {}}
    },
    config: {
        name: "zoonet",
        base_path: "/tf-models/zoonet",
        model_platform: "tensorflow",
        model_version_policy: {all: {}}
    }
}
```

we can now follow our previous steps of zipping the tf-models folder and saving the zipped file on AWS S3. Cruise will automatically identify the models and serve all of them. to access zoonet we can use this URL:

```
https://YOUR-APP-NAME.herokuapp.com/v1/models/zoonet
```

<br/>
<br/>

# Summary

Cruise can help you easily deploy your model as a rest api and is extremely helpful when you are working on a team or trying to quickly showcase your Tensorflow models.

The only downside to cruise is that it isn't designed in a CI/CD version which means if you ever want to add a new model version or add a new model to your heroku server you would have to either delete the app and start the process all over or visit your app settings page, tunr the app off, modify the bucket url to a new url holding your new model versions or entirely new models and then restart the app.

Cruise wasn't originally designed for such a use case as the vision was to help people quickly share models as apis or help teams without MLOPS engineers quickly deploy final versions of their tensorflow models as a micro service that can be used by other teams.

for more details on how tensorflow serving works you can refer to:

- The [doumentation](https://www.tensorflow.org/tfx/guide/serving)

- This [Tutorial](https://neptune.ai/blog/how-to-serve-machine-learning-models-with-tensorflow-serving-and-docker) written by Rising Odegua

Also note that Tensorflow model training code used for the example in this documentation were adopted from this [article](https://neptune.ai/blog/how-to-serve-machine-learning-models-with-tensorflow-serving-and-docker)
