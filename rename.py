import os
  
# Function to rename multiple files
directory = "/tmp/1080p/"
def main():
    for count, filename in enumerate(os.listdir(directory)):

        src = directory + filename
        # dst =  directory + str(count) + filename
        # os.rename(src, dst)
        dst = directory + (filename.split("]")[1].split("Multi")[0].strip() + ".mkv")
        os.rename(src,dst)
  
# Driver Code
if __name__ == '__main__':
      
    # Calling main() function
    main()