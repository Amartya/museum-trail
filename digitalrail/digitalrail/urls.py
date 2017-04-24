"""digitalrail URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.9/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import include,url
from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static

from  digitalrail.views import landingpage

urlpatterns = [
    url(r'^$', landingpage.index, name='index'),
                  url(r'^admin/', admin.site.urls),
    url(r'^bigquestion/', landingpage.bigquestion, name='bigquestion'),
    url(r'^imodel/', landingpage.imodel, name='imodel'),
    url(r'^slidemain/', landingpage.slidemain, name='slidemain'),
    url(r'^beaconviz/', landingpage.beaconviz, name='beaconviz'),
    url(r'^experiments/', landingpage.experiments, name='experiments'),
    url(r'^setwatchstatus/$', landingpage.setwatchstatus, name='setwatchstatus'),
    url(r'^getwatchstatus/$', landingpage.getwatchstatus, name='getwatchstatus'),
    url(r'^resetwatchstatus/$', landingpage.getwatchstatus, name='resetwatchstatus'),
    url(r'^setwatchstory/$', landingpage.setwatchstory, name='setwatchstory'),
    url(r'^getwatchstory/$', landingpage.getwatchstory, name='getwatchstory'),
    url(r'^setdisplaystory/$', landingpage.setdisplaystory, name='setdisplaystory'),
    url(r'^getdisplaystory/$', landingpage.getdisplaystory, name='getdisplaystory'),
    url(r'^savedata/$', landingpage.savedata, name='savedata'),
    url(r'^getsavedata/$', landingpage.getsavedata, name='getsavedata'),

] +  static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

