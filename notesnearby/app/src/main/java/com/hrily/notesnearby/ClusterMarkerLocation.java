package com.hrily.notesnearby;

import com.google.android.gms.maps.model.LatLng;
import com.google.maps.android.clustering.ClusterItem;

public class ClusterMarkerLocation implements ClusterItem {

    private LatLng position;
    private Note note;

    public ClusterMarkerLocation( LatLng latLng , Note n) {
        position = latLng;
        note = n;
    }

    @Override
    public LatLng getPosition() {
        return position;
    }

    public Note getNote() {
        return note;
    }

    public void setPosition( LatLng position ) {
        this.position = position;
    }
}
