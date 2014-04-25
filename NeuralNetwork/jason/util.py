import csv

class util:

    @staticmethod
    def col( matrix, i):
        return [row[i] for row in matrix]

    @staticmethod
    def get_data(filepath):

        headers = []
        data = []
        classes = []

        # loop through the csv and get each row
        with open(filepath, 'rb') as csvfile:
            # reader reads the csv
            reader = csv.reader(csvfile, delimiter=',', quotechar='|')

            counter = 0

            # append to the list the row
            for row in reader:

                if counter == 0:
                    headers = row
                else:
                    data.append(row[0:(len(row)-1)])
                    classes.append(row[-1])

                counter += 1

        return headers, data, classes

    @staticmethod
    def matrix_to_float(data):
        return [[float(i) for i in row] for row in data]

    @staticmethod
    def unique_list(l):
        return list(set(l))