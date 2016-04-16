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

	List<String> words;
	List<Snippet> snippets;

	public static void main(String [ ] args)
	{
		Snippet s = new Snippet();	
		s.words=new ArrayList<>();
		s.readOriginal();

		
		s.snippets = new ArrayList<>();
		s.snipetize(s.words);
		
	//	System.out.println("insdie main\n");
		s.OutputFile();

	}

	public  void readOriginal()
	{
		try
		{
			BufferedReader in = new BufferedReader(new FileReader("Data.txt"));
			System.out.println("Input \n");

			while ((str = in.readLine()) != null) {
				System.out.println(str);
				ar=str.split(" ");
				for(int i=0;i<ar.length;i++)
				{
					words.add(ar[i]);
				}
			}
			in.close();
		} catch (IOException e) {
			System.out.println("File Read Error");
		}

	}

	public void snipetize (List<String> wordList)
	{
		System.out.println("\nOutput\n");

		for (int j = 0; j < wordList.size(); j++) 
		{
			String regEx = "('|\\||>|&|}|A|d|\\*|r|z|W|Y)";
			String snipiitedWord = wordList.get(j).replaceAll(regEx, "$1 ");
			
			String splittedWords[] = snipiitedWord.split(" ");
			
		//	System.out.println("inside the snipetize function\n");
			
			System.out.println(snipiitedWord);

			
			Snippet currentSnippet = null;
			
			for (int i = 0; i < splittedWords.length; i++)
			{
				currentSnippet = new Snippet();
		
				currentSnippet.text = splittedWords[i];
				currentSnippet.type = "let";
				currentSnippet.lastChar = splittedWords[i]
						.charAt(splittedWords[i].length() - 1);
				if (i == 0)
					currentSnippet.tag = "B";
				else if (i == splittedWords.length - 1)
					currentSnippet.tag = "E";
				else
					currentSnippet.tag = "I";
				
			}
			snippets.add(currentSnippet);
		}
	}

	public  void OutputFile() 
	{
		try 
		{
			BufferedWriter out = new BufferedWriter(new FileWriter("output.txt"));
			for (int i = 0; i < snippets.size(); i++) 
			{
				out.write(snippets.get(i).text + "\n");
				//System.out.println(snippets.get(i).text);
			}
			out.close();
		} catch (IOException e) {}
	}
	
}



