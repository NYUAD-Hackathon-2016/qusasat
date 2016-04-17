package com.qusasat.snippet;

import java.util.List;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;


public class Snippet
{
    String mText;
    String mType;
    String mTag;
    char mLastChar;
    String mNiceLastChar; // Programmers are funny!! We just can't help it :3

    List<String> mWords;
    List<Snippet> mSnippets;

    public static void main(String[] args)
    {
        Snippet s = new Snippet();
        s.mWords = new ArrayList<>();

        // Get the training data from a text file
        s.readDataFile();

        // Chop words into Snippet objects
        s.snippetize();

        // Create the CRF++-compliant input file
        s.createCRFFile();

    } // end main

    public void readDataFile()
    {
        try
        {
            String lineHolder;
            String arrayHolder[];
            
            BufferedReader bufferedReader = new BufferedReader(new FileReader("train.txt"));

            while ((lineHolder = bufferedReader.readLine()) != null)
            {
                arrayHolder = lineHolder.split(" ");
                for(int i = 0; i < arrayHolder.length; i++)
                {
                    // Remove punctuations
                    arrayHolder[i] = arrayHolder[i].replaceAll("[^\\'|>&<}AbptvjHxd*rzs$SDTZEg_fqklmnhwYyFNKaui~o]", "");

                    // Replace ' with Q for compatibility with CRF++
                    arrayHolder[i] = arrayHolder[i].replaceAll("'", "Q");

                    // Remove double and trible spaces
                    arrayHolder[i] = arrayHolder[i].replaceAll("  ", " ");
                    arrayHolder[i] = arrayHolder[i].replaceAll("   ", " ");

                    if(arrayHolder[i].length() > 0)
                    {
                        mWords.add(arrayHolder[i]);

                    } // end if

                } // end for

            } // end while

            bufferedReader.close();

        } // end try

        catch (IOException e)
        {
            System.out.println("File read error");

        } // end catch

    } // end method readDataFile

    public void snippetize()
    {
        mSnippets = new ArrayList<Snippet>();

        for (int j = 0; j < mWords.size(); j++)
        {

            // Adding spaces after non-connected letters
            String regEx = "(Q|\\||>|&|}|A|d|\\*|r|z|W|Y)";
            String spacedTextHolder = mWords.get(j).replaceAll(regEx, "$1 ");

            String splittedTextHolder[] = spacedTextHolder.split(" ");

            Snippet currentSnippet = null;

            for (int i = 0; i < splittedTextHolder.length; i++)
            {
                // Construct the current Snippet object
                currentSnippet = new Snippet();

                currentSnippet.mText = splittedTextHolder[i];
                currentSnippet.mType = "let";
                currentSnippet.mLastChar = splittedTextHolder[i]
                        .charAt(splittedTextHolder[i].length() - 1);
                currentSnippet.mNiceLastChar =isLastCharNice(splittedTextHolder[i]);

                if (i == 0)
                {
                    currentSnippet.mTag = "B";

                } // end if
                else
                {
                    currentSnippet.mTag = "I";

                } // end else

                mSnippets.add(currentSnippet);

            } // end inner for

        } // end outer for

    } // end method snippetize


    public void createCRFFile()
    {
        try
        {
            BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter("trainCRF.txt"));

            for (int i = 0; i < mSnippets.size(); i++)
            {
                bufferedWriter.write(mSnippets.get(i).mText +"\t"+ mSnippets.get(i).mLastChar +"\t" +
                        mSnippets.get(i).mNiceLastChar +"\t" + mSnippets.get(i).mTag +"\n");

            } // end for

            bufferedWriter.close();

        } // end try

        catch (IOException e)
        {
            System.out.println("Output file error!!");

        } // end catch

    } // end method createCRFFile

	/*
	 * ****** Helper methods *******
	 */

    public String isLastCharNice(String snippetText)
    {

        if(snippetText.endsWith("\\")||snippetText.endsWith("|")||snippetText.endsWith(">")||
                snippetText.endsWith("<")||snippetText.endsWith("}")||snippetText.endsWith("A")||
                snippetText.endsWith("*")||snippetText.endsWith("r")||snippetText.endsWith("z")||
                snippetText.endsWith("w")||snippetText.endsWith("Y"))
        {
            return "F";
            
        } // end if 
        
        return "T";

    } // end method isLastCharNice

} // end class Snippet
