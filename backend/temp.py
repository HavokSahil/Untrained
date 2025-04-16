seat_types = ['LL', 'MD', 'UP', 'SL', 'SU', 'ST', 'FC']
insert_statements = []
seat_no = 1

for coach_id in range(1, 91):  # Assuming 90 coaches
    for i in range(10):  # 10 seats per coach
        seat_type = seat_types[i % len(seat_types)]
        insert_statements.append(f"({i+1}, '{seat_type}', {coach_id}, 'CNF')")

sql = "INSERT INTO seat (seat_no, seat_type, coach_id, seat_category) VALUES\n" + ",\n".join(insert_statements) + ";"
print(sql)

