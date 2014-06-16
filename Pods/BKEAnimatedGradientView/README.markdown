# BKEAnimatedGradientView

Easily animate gradient transitions on UIViews. View it in [action](http://c.minicorp.ie/0k1g2Q1W1p0H).

![Screenshot](http://f.cl.ly/items/1Z0l3c170I2D2t223z18/BKEAnimatedGradientView.gif)

## Example Usage

```objective-c
BKEAnimatedGradientView *gradientView = [[BKEAnimatedGradientView alloc] initWithFrame:self.view.frame];
[gradientView setGradientColors:@[[UIColor blueColor], [UIColor greenColor]]];
[self.view addSubview:gradientView];

[gradientView changeGradientWithAnimation:@[[UIColor redColor], [UIColor orangeColor]] delay:1 duration:5];
```

## Adding To Your Project

### Manually

Simply add the files `BKEAnimatedGradientView.h` and `BKEAnimatedGradientView.m` to your project.