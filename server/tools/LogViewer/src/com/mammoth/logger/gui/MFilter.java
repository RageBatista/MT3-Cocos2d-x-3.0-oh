package com.mammoth.logger.gui;

import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;

import com.mammoth.logger.Log;

public class MFilter extends ViewerFilter {
    public boolean select(Viewer viewer, Object parentElement, Object element) {
        Log log = (Log)element;
//        return p.getName().startsWith("张1");
        return log.isMarked();
    }
}