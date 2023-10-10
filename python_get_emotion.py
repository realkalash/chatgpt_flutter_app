from text2emotion import Text2Emotion

# text = """
# Bill Gates, born William Henry Gates III on October 28, 1955, is an American business magnate, software developer, and philanthropist. He co-founded Microsoft Corporation, one of the world's largest and most successful technology companies, with Paul Allen in 1975. Gates played a pivotal role in the personal computer revolution, leading Microsoft to become the dominant player in the software industry.

# As the co-founder and former CEO of Microsoft, Gates played a significant role in the development of groundbreaking software products, including the MS-DOS operating system and the Microsoft Windows operating system, which revolutionized the way people interact with computers. Microsoft's success propelled Gates to become one of the wealthiest individuals in the world.
# """


def analyze_emotion(text):
    t2e = Text2Emotion()
    emotion = t2e.get_emotion(text)
    return emotion

if __name__ == "__main__":
    input_text = input("Enter the text: ")
    result = analyze_emotion(input_text)
    print(result)