import java.util.List;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;


public class Snippet 
{
	String str;
	String ar[];


	String text;
	String type;
	String tag;
	char lastChar;
	String niceLastChar;

	List<String> words;
	List<Snippet> snippets;

	public static void main(String [ ] args)
	{
		Snippet s = new Snippet();	
		s.words=new ArrayList<>();
		s.readOriginal();
		
		s.snipetize(s.words);
		s.OutputFile();

	}

	public  void readOriginal()
	{
		try
		{
			BufferedReader in = new BufferedReader(new FileReader("train.txt"));
		

			while ((str = in.readLine()) != null) {
				ar=str.split(" ");
				for(int i=0;i<ar.length;i++)
				{
					ar[i] = ar[i].replaceAll("[^\\'|>&<}AbptvjHxd*rzs$SDTZEg_fqklmnhwYyFNKaui~o]", "");
					ar[i] = ar[i].replaceAll("'", "Q");
					ar[i] = ar[i].replaceAll("  ", " ");
					ar[i] = ar[i].replaceAll("   ", " ");
					if(ar[i].length()>0)
					{
						words.add(ar[i]);

					}


				}
			}
			in.close();
		} catch (IOException e) {
			System.out.println("File Read Error");
		}

	}

	public void snipetize (List<String> wordList)
	{
		snippets = new ArrayList<Snippet>();

		for (int j = 0; j < wordList.size(); j++) 
		{
		
			String regEx = "(Q|\\||>|&|}|A|d|\\*|r|z|W|Y)";
			String snipittedWord = wordList.get(j).replaceAll(regEx, "$1 ");
			
			String splittedWords[] = snipittedWord.split(" ");
			
		
			
			Snippet currentSnippet = null;
			
			for (int i = 0; i < splittedWords.length; i++)
			{
				currentSnippet = new Snippet();
		
				currentSnippet.text = splittedWords[i];
				currentSnippet.type = "let";
				currentSnippet.lastChar = splittedWords[i]
						.charAt(splittedWords[i].length() - 1);
				currentSnippet.niceLastChar=isLastCharNice(splittedWords[i]);

				if (i == 0)
					currentSnippet.tag = "B";
				else
					currentSnippet.tag = "I";
				

				snippets.add(currentSnippet);
				
			}
			
	
		}
	}


	public  void OutputFile() 
	{
		try 
		{
			BufferedWriter out = new BufferedWriter(new FileWriter("trainCRF.txt"));
			
			
			for (int i = 0; i < snippets.size(); i++) 
			{
				out.write(snippets.get(i).text+"\t"+snippets.get(i).lastChar+"\t" +snippets.get(i).niceLastChar +"\t" +snippets.get(i).tag+"\n");
			}
			
			
			out.close();
		} catch (IOException e) {}
	}
	
	/*
	 * ****** Helper funcitons
	 */
	
	public String isLastCharNice(String snippetText)
	{
		
		if(snippetText.endsWith("\\")||snippetText.endsWith("|")||snippetText.endsWith(">")||
				snippetText.endsWith("<")||snippetText.endsWith("}")||snippetText.endsWith("A")||
				snippetText.endsWith("*")||snippetText.endsWith("r")||snippetText.endsWith("z")||
				snippetText.endsWith("w")||snippetText.endsWith("Y"))
		{
			return "F";
			
		}
		return "T";
	
		
		
		
	}
	
}



