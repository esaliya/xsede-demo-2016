package edu.indiana.soic.spidal.xsede.utils;

import com.google.common.base.Strings;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Date;
import java.util.regex.Pattern;

public class PvizBuilder {
    public static void main(String[] args) {
        String pointsFile = args[0];
        String outDir = args[1];
        int numPoints = Integer.parseInt(args[2]);
        int dim = Integer.parseInt(args[3]);

        Date date = new Date();
        String dateStr = date.toString().replace(' ', '-').replace(':','.');
        System.out.println(dateStr);

        String name = com.google.common.io.Files.getNameWithoutExtension(pointsFile);
        String templateFile = "template.pviz";
        try(BufferedReader pr = Files.newBufferedReader(Paths.get(pointsFile), Charset.defaultCharset());
            BufferedReader tr = new BufferedReader(new InputStreamReader(PvizBuilder.class.getClassLoader().getResourceAsStream(templateFile)));
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
