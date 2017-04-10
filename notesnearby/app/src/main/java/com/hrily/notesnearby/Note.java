package com.hrily.notesnearby;

public class Note {
    public double lat, lng;
    public String title;
    public String desc;
    public String img;

    public String id;

    public Note(){}

    public Note(double lat, double lng, String title, String desc, String img) {
        this.lat = lat;
        this.lng = lng;
        this.title = title;
        this.desc = desc;
        this.img = img;
    }

    public Note(double lat, double lng, String title, String desc) {
        this.lat = lat;
        this.lng = lng;
        this.title = title;
        this.desc = desc;
    }

    public double getLat() {
        return lat;
    }

    public void setLat(double lat) {
        this.lat = lat;
    }

    public double getLng() {
        return lng;
    }

    public void setLng(double lng) {
        this.lng = lng;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public String getImg() {
        return img;
    }

    public void setImg(String img) {
        this.img = img;
    }

}
