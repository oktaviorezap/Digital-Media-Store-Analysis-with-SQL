-- Task 1: How Much Data in the Album Table
select 
	count(*)
from
	exercise_pacmann.album;
-- Jawaban : Jumlah Data pada Tabel Album ada 347 Data



-- 1. Top 10 Negara dengan Jumlah Invoice Terbanyak
	select 
		country,
		sum(jumlah_invoice) total_invoice
	from 
		(
			select
				customerid,
				country
			from
				exercise_pacmann.customer
		) as c
	inner join
		(
			select
				customerid,
				count(invoiceid) as jumlah_invoice
			from
				exercise_pacmann.invoice
			group by
				customerid
		) as i
	on
		c.customerid = i.customerid
	group by
		country
	order by
		total_invoice desc,
		country
	limit
		10;
-- Jawaban : USA menjadi negara dengan Jumlah Unique Invoice Terbanyak yaitu sebanyak 91 Invoice
	

	
-- 2. Mencari Top 10 Genres berdasarkan Total Sales
-- Total Sales = Quantity * Price
with 
	track_genre 
as
(
	select
		trackid,
		name as genre_name
	from
		exercise_pacmann.genre g
	inner join
		(
			select
				genreid,
				trackid
			from
				exercise_pacmann.track 
		) as t
	on
		g.genreid = t.genreid
)
select
	genre_name,
	sum(quantity * unitprice) as total_sales
from
	track_genre tg
inner join
	(
		select
			trackid,
			unitprice,
			quantity
		from
			exercise_pacmann.invoiceline
	) as il
on
	tg.trackid = il.trackid
group by
	genre_name
order by
	total_sales desc 
limit 
	10;
-- Jawaban: Genre Rock adalah genre dengan Penjualan Tertinggi yaitu sebanyak 826.65



-- 3. Top 10 Customer Spender
with 
	cust_invoice
as
(
	select
		*
	from 
		(
			select 
				customerid,
				concat(firstname,' ',lastname) as customername,
				email
			from
				exercise_pacmann.customer
		) as c
	join
		(
			select
				customerid,
				invoiceid
			from
				exercise_pacmann.invoice
		) as i
	on
		c.customerid = i.customerid
)
select 
	customername,
	email,
	sum(quantity * unitprice) as total_spending
from 
	cust_invoice ci
inner join
	(
		select
			invoiceid,
			quantity,
			unitprice
		from
			exercise_pacmann.invoiceline 
	) as i
on
	ci.invoiceid = i.invoiceid
group by
	customername, 
	email
order by 
	total_spending desc
limit 
	10;
-- Jawaban: Customer atas nama Helena Hol adalah Top Spender tertinggi dengan total spending 49.62



-- 4. Berikan Data Negara dengan Total Invoice Terbanyak berdasarkan Jawaban Nomor 1
-- Tampilkan Country, City dan Total Invoice
create view 
	top10_country_invoices
as
	select 
		country,
		sum(jumlah_invoice) total_invoice
	from 
		(
			select
				customerid,
				country
			from
				exercise_pacmann.customer
		) as c
	inner join
		(
			select
				customerid,
				count(invoiceid) as jumlah_invoice
			from
				exercise_pacmann.invoice
			group by
				customerid
		) as i
	on
		c.customerid = i.customerid
	group by
		country
	order by
		total_invoice desc,
		country
	limit
		10;

select
	country,
	city,
	sum(jumlah_invoice) as total_invoice
	from
	(
		select 
			c.customerid,
			country,
			city,
			count(invoiceid) as jumlah_invoice
		from 
			(
				select
					customerid,
					country,
					city
				from
					exercise_pacmann.customer
			) as c
		inner join
			(
				select
					customerid,
					invoiceid 
				from
					exercise_pacmann.invoice
			) as i
		on
			c.customerid = i.customerid
		group by
			c.customerid,
			country,
			city
	) as t1
where 
	country in (
					select
						country
					from
						exercise_pacmann.top10_country_invoices tci 
			   )
group by
	country,
	city
order by
	total_invoice desc;
-- Jawaban: Kota London, Mountain View, Paris, Berlin, Prague, Sao Pulo adalah Kota-Kota yang invoice nya terbanyak sebanyak 14 Invoice



-- 5. Memilih 4 dari 6 Lagu untuk dimasukkan dalam Toko (Store)
with 
	customer_invoice_track
as
(
	select
		customerid,
		country,
		il.invoiceid,
		trackid,
		quantity
	from
	(
		select 
			c.customerid,
			country,
			invoiceid
		from 
			(
				select
					customerid,
					country
				from
					exercise_pacmann.customer
				where 
					country = 'United Kingdom'
			) as c
		inner join
			(
				select
					customerid,
					invoiceid 
				from
					exercise_pacmann.invoice
			) as i
		on
			c.customerid = i.customerid
	) as cust_country_invoice
	inner join 
		(
			select
				invoiceid,
				trackid,
				quantity
			from
				exercise_pacmann.invoiceline  
		) as il
	on
		cust_country_invoice.invoiceid = il.invoiceid
)
select
	country,
	genre,
	sum(quantity) as purchase_total
from
	customer_invoice_track as cit
join
	(
		select
			trackid,
			t.genreid,
			t.name as song_name,
			g.name as genre
		from
			exercise_pacmann.track t
		join
			exercise_pacmann.genre g
		on
			t.genreid = g.genreid
	) as t_join
on
	cit.trackid = t_join.trackid
group by
	country,
	genre
order by 
	purchase_total desc;
-- Jawaban: Berdasarkan hasil query temuan bahwa Lagu Genre Rock yang paling banyak dibeli, sehingga
-- 4 lagu yang dapat ditambahkan adalah genre Rock, Reggae, Jazz, Hip Hop/Rap
-- Sehingga lagu yang dapat ditambahkan adalah "Good to See You": Rock, "Got Ya Before Sunrise":Reggae, "Nothing On You":Jazz, "Before The Coffee Gets Cold":Hip Hop/Rap 



-- 6. Album that Popular in USA
with 
	invoice_track_qty
as
(
	select
		invoiceid,
		trackid,
		quantity
	from
		(
			select 
				customerid,
				country
			from
				exercise_pacmann.customer
			where 
				country = 'USA'
		) as cust_country
	inner join
		(
			select
				customerid,
				i.invoiceid,
				trackid,
				quantity
			from
			(	
				select
					customerid,
					invoiceid
				from
					exercise_pacmann.invoice
			) as i
			inner join
				(
					select
						invoiceid,
						trackid,
						quantity
					from
						exercise_pacmann.invoiceline
				) as il
			on
				i.invoiceid = il.invoiceid
		) as invoice_track
	on
		cust_country.customerid = invoice_track.customerid
)
select 
	album_title,
	sum(quantity) as total_purchase
from 
	invoice_track_qty itq
inner join
	(
		select
			trackid,
			title as album_title
		from
			(
				select
					trackid,
					albumid
				from
					exercise_pacmann.track
			) as t
		inner join
			(
				select
					albumid,
					title
				from
					exercise_pacmann.album
			) a
		on
			t.albumid = a.albumid
	) a
on
	itq.trackid = a.trackid
group by
	album_title
order by 
	total_purchase desc
limit 
	10;
-- Jawaban: The Office, Season 3 menjadi yang tertinggi dari Top 10 Album terpopuler di USA dengan 14 Pesanan. 
-- Kemudian diikuti Prenda Minha, Unplugged, Chill: Brazil (Disc 2), Back to Black, International Superhits, dsb



-- 7. Buat Tabel Aggregate Purchase Data by Country
	with
		sales_summary
	as 
	(
		with
			invoice_cust
		as 
		(
			select
				c.customerid,
				country,
				invoiceid
			from
				(
					select 
						customerid,
						country
					from
						exercise_pacmann.customer
				) c
			inner join
				(
					select
						customerid,
						invoiceid
					from
						exercise_pacmann.invoice
				) i
			on
				c.customerid = i.customerid
		)
		select
			case 
				when
					count(distinct customerid) = 1
				then 
					'Other'
				else
					country
			end as country,
			count(distinct customerid) as unique_customer_cnt,
			sum(quantity * unitprice) as total_value_of_sales,
			count(distinct ic.invoiceid) as total_order		
		from
			invoice_cust ic
		inner join
			(
				select
					invoiceid,
					quantity,
					unitprice
				from
					exercise_pacmann.invoiceline 
			) il
		on
			ic.invoiceid = il.invoiceid 
		group by 
			country
		order by 
			country
	)
	select
		country,		
		sum(unique_customer_cnt) as total_number_of_customers,
		sum(total_value_of_sales) as total_value_of_sales,
		sum(total_value_of_sales) / sum(unique_customer_cnt) as avg_value_of_sales_per_cust,
		sum(total_value_of_sales) / sum(total_order) as avg_order_value 
	from
		sales_summary
	group by
		country
	order by
		country;
-- Jawaban:
--	1. Total Customer Tertinggi adalah USA sebanyak 13 customer (Others tidak dihitung karena terdiri dari banyak negara)
--	2. Total Value of Sales Tertinggi adalah USA dengan 523.06
--	3. Average Value of Sales per Customer tertinggi adalah Czech Republic
--	4. Average Order Value (AOV) tertinggi adalah Czech Republic dengan 6.45

	
	
-- 8. Mencari genre yang sales nya jelek di USA
	with
		sales_summary
	as
	(
	with 
		customer_invoice_track
	as
	(
		select
			customerid,
			country,
			il.invoiceid,
			trackid,
			quantity,
			unitprice
		from
		(
			select 
				c.customerid,
				country,
				invoiceid
			from 
				(
					select
						customerid,
						country
					from
						exercise_pacmann.customer
					where 
						country = 'USA'
				) as c
			inner join
				(
					select
						customerid,
						invoiceid 
					from
						exercise_pacmann.invoice
				) as i
			on
				c.customerid = i.customerid
		) as cust_country_invoice
		inner join 
			(
				select
					invoiceid,
					trackid,
					quantity,
					unitprice
				from
					exercise_pacmann.invoiceline  
			) as il
		on
			cust_country_invoice.invoiceid = il.invoiceid
	)
	select
		country,
		genre,
		sum(quantity) as qty,
		sum(quantity * unitprice) as total_sales
	from
		customer_invoice_track as cit
	join
		(
			select
				trackid,
				t.genreid,
				t.name as song_name,
				g.name as genre
			from
				exercise_pacmann.track t
			join
				exercise_pacmann.genre g
			on
				t.genreid = g.genreid
		) as t_join
	on
		cit.trackid = t_join.trackid
	group by
		country,
		genre
	order by 
		total_sales
)
select
	*,
	case
		when
			total_sales < avg(total_sales) over()
		then
			'Total Sales Below Sales Average'
		else
			'Total Sales Above Sales Average'
	end as sales_category
from
	sales_summary
;	
-- Jawaban : Genre selain Rock, Latin, Metal, Alternative & Punk dan TV Shows berada di bawah Rata-Rata Penjualan
-- Sehingga Genre tersebut perlu untuk di boost sales nya

	
	
-- 9. Mencari Lagu yang bisa diiklankan berdasarkan Customer Spending per Genre
with
	cust_spend_genre
as
(
	with 
		cust_invoice_track
	as	
	(
		select
			customerid,
			lastname,
			firstname,
			il.invoiceid,
			trackid,
			quantity,
			unitprice
		from
			(
				select 
					c.customerid,
					lastname,
					firstname,
					invoiceid
				from
					exercise_pacmann.customer c
				inner join
					exercise_pacmann.invoice i 
				on
					c.customerid = i.customerid
			) cust_invoice
		inner join
			exercise_pacmann.invoiceline il
		on
			il.invoiceid = cust_invoice.invoiceid
	)
	select
		customerid,
		firstname,
		lastname,
		genre,
		sum(quantity * unitprice) as total_sales
	from
		cust_invoice_track cit
	inner join
		(
			select
				trackid,
				g.name as genre
			from
				exercise_pacmann.track t
			inner join
				exercise_pacmann.genre g
			on
				t.genreid = g.genreid		
		) t
	on
		cit.trackid = t.trackid
	group by
		customerid,
		firstname,
		lastname,
		genre
	order by
		customerid,
		total_sales desc
)
select 
	customerid,
	firstname,
	lastname,
	genre,
	total_sales,
	dense_rank() over(partition by customerid order by total_sales desc) as genre_rank_per_customer
from
	cust_spend_genre
order by
	total_sales desc;

-- Jawaban : Genre Rock adalah Genre yang diminati setiap Customer yang bertransaksi yaitu sebanyak 43 Customer dan Eduardo Martins adalah customer peminat Rock dengan Total Sales Tertinggi



-- 10. Negara yang Spending Customernya paling banyak
	select
		country,
		sum(quantity * unitprice) as total_sales
	from
		(
			select
				country,
				invoiceid
			from
				exercise_pacmann.customer c
			inner join
				exercise_pacmann.invoice i
			on	
				c.customerid = i.customerid
		) as t_cust
	inner join
		exercise_pacmann.invoiceline il
	on	
		t_cust.invoiceid = il.invoiceid
	group by 
		country
	order by
		total_sales desc
	limit 10;