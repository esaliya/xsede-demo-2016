package edu.indiana.soic.spidal.xsede.utils;

import com.google.common.base.Strings;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.regex.Pattern;

public class PvizBuilder {
    public static void main(String[] args) {
        String pointsFile = args[0];
        String outDir = args[1];
        int numPoints = Integer.parseInt(args[2]);
        int dim = Integer.parseInt(args[3]);

        String name = com.google.common.io.Files.getNameWithoutExtension(pointsFile);
        String templateFile = "template.pviz";
        try(BufferedReader pr = Files.newBufferedReader(Paths.get(pointsFile), Charset.defaultCharset());
            BufferedReader tr = Files.newBufferedReader(Paths.get(templateFile), Charset.defaultCharset());
            BufferedWriter bw = Files.newBufferedWriter(Paths.get(outDir, name + ".pviz"))) {

            PrintWriter pw = new PrintWriter(bw, true);
            double[][] points = new double[numPoints][dim];
            Pattern pat = Pattern.compile("\t");
            String line;
            String [] splits;
            int idx = 0;
            double [] point;

            String[] dimLetters = new String[]{"x=","y=","z="};
            while ((line = pr.readLine()) != null){
                if (Strings.isNullOrEmpty(line)) continue;
                splits = pat.split(line);
                point = points[idx];
                for (int i = 0; i < dim; ++i){
                    point[i] = Double.parseDouble(splits[i+1]);
                }
                ++idx;
            }

            while ((line = tr.readLine()) != null){
                if (Strings.isNullOrEmpty(line)) continue;
                if (!line.contains("<point>")){
                    pw.println(line);
                    continue;
                }
                // Processing a point
                pw.println(line);
                line = tr.readLine();
                int beginIndex = line.indexOf('>') + 1;
                int key = Integer.parseInt(line.substring(beginIndex, line.indexOf('<', beginIndex)));
                pw.println(line);
                pw.println(tr.readLine());
                pw.println(tr.readLine());
                pw.print("<location ");
                point = points[key];
                for (int i = 0; i < dim; ++i){
                    pw.print(dimLetters[i]+ "\"" + point[i] + "\" ");
                }
                pw.println("/>");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
