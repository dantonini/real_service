package com.realservice;

import java.io.File;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.xhtmlrenderer.simple.PDFRenderer;

@SuppressWarnings("all")
public class FatturaOrdineDiScarico {
  public static void main(final String[] args) {
    try {
      File _file = new File("ddt-sample.html");
      File _file_1 = new File("out.pdf");
      String _absolutePath = _file_1.getAbsolutePath();
      PDFRenderer.renderToPDF(_file, _absolutePath);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
