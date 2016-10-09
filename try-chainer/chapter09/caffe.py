import numpy as np
import chainer
import chainer.functions as F
from chainer import Variable
from chainer.functions import caffe
from PIL import Image

image = Image.open('.data/image01.jpg').convert('RGB')

fixed_w, fixed_h = 224, 224
w, h = image.size
if w > h:
    shape = (int(fixed_w * w / h), fixed_h)
else:
    shape = (fixed_w, int(fixed_h * h / w))


left = (shape[0] - fixed_w) // 2
top = (shape[1] - fixed_h) // 2
right = left + fixed_w
bottom = top + fixed_h

image = image.resize(shape)
image = image.crop((left, top, right, bottom))

x_data = np.asarray(image).astype(np.float32)
# print(x_data.shape)
# print(x_data[100, 100, 0:3])
x_data = x_data.transpose(2, 0, 1)[::-1]
# print(x_data.shape)
# print(x_data[0:3, 100, 100])

mean_image = np.ndarray((3, fixed_w, fixed_h), dtype=np.float32)
mean_image[0] = 104
mean_image[1] = 117
mean_image[2] = 123

x_data -= mean_image

x_batch = np.array([x_data])
x = Variable(x_batch)


func = caffe.CaffeFunction('.data/bvlc_googlenet.caffemodel')
y, = func(inputs={'data': x}, outputs=['loss3/classifier'], train=False)
prob = F.softmax(y)

max_id = np.argmax(prob.data[0])
print('label-id: {0}, prob: {1}'.format(max_id, prob.data[0, max_id]))
