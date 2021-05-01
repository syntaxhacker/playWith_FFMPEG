import os
  
# Function to rename multiple files
directory = "/tmp/IronMan/"
def main():
    for count, filename in enumerate(os.listdir(directory)):

        src = directory + filename
        # dst =  directory + str(count) + filename
        # os.rename(src, dst)
        # dst = directory + (filename.split("]")[1].split("Multi")[0].strip() + ".mkv")
        # dst = directory + (filename.split(" "))
        file = filename.split(' ')[1:][0 : 2] 
        file = "".join(file)
        final = directory + (file + " " + filename.split(' ')[1:][3].split(".")[1] + ".mkv")
        os.rename(src,final)
  
# Driver Code
if __name__ == '__main__':
      
    # Calling main() function
    main()