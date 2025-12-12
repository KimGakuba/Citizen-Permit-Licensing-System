"""
Complete Permit Management System - ALL ERRORS FIXED
Requirements: pip install oracledb
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import oracledb
from datetime import datetime
import csv
import json

# Database configuration
DB_CONFIG = {
    'user': 'gakuba',
    'password': 'Kim',
    'dsn': 'localhost:1521/thu_27670_kim_permit_db'
}

def safe_convert(val):
    """Convert database values safely"""
    if val is None:
        return ''
    elif isinstance(val, datetime):
        return val.strftime('%Y-%m-%d %H:%M:%S')
    elif hasattr(val, 'read'):
        try:
            return str(val.read())
        except:
            return str(val)
    return str(val)

class DatabaseManager:
    def __init__(self, config):
        self.config = config
        self.connection = None
        
    def connect(self):
        try:
            self.connection = oracledb.connect(**self.config)
            return True
        except oracledb.Error as e:
            messagebox.showerror("Connection Error", str(e))
            return False
    
    def disconnect(self):
        if self.connection:
            try:
                self.connection.close()
            except:
                pass
    
    def execute_query(self, query, params=None):
        try:
            cursor = self.connection.cursor()
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)
            results = cursor.fetchall()
            cursor.close()
            return results
        except oracledb.Error as e:
            messagebox.showerror("Query Error", str(e))
            return []

class PermitManagementApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Permit & License Management System - Rwanda")
        self.root.geometry("1400x800")
        self.root.configure(bg='#ecf0f1')
        
        self.db = DatabaseManager(DB_CONFIG)
        if not self.db.connect():
            messagebox.showerror("Fatal Error", "Cannot start without database")
            self.root.quit()
            return
        
        self.create_menu()
        self.create_main_layout()
        self.show_dashboard()
        
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
    
    def create_menu(self):
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Export Audit Logs (CSV)", command=self.export_audit_logs)
        file_menu.add_command(label="Export Audit Logs (JSON)", command=self.export_audit_json)
        file_menu.add_command(label="Export All Data", command=self.export_all_data)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.on_closing)
        
        ops_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Operations", menu=ops_menu)
        ops_menu.add_command(label="Register Citizen", command=self.show_register_citizen)
        ops_menu.add_command(label="Submit Application", command=self.show_submit_application)
        ops_menu.add_command(label="Process Payment", command=self.show_process_payment)
        ops_menu.add_command(label="Add Review Step", command=self.show_add_review)
        ops_menu.add_separator()
        ops_menu.add_command(label="Check Operation Allowed", command=self.check_operation_allowed)
        ops_menu.add_command(label="Bulk Update Status", command=self.show_bulk_update)
        
        reports_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Reports", menu=reports_menu)
        reports_menu.add_command(label="Monthly Revenue", command=self.show_monthly_revenue)
        reports_menu.add_command(label="Department Performance", command=self.show_dept_performance)
        reports_menu.add_command(label="Top Permit Types", command=self.show_top_permits)
        reports_menu.add_command(label="Calculate Revenue", command=self.calculate_revenue)
        
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="About", command=self.show_about)
    
    def create_main_layout(self):
        self.sidebar = tk.Frame(self.root, bg='#2c3e50', width=200)
        self.sidebar.pack(side=tk.LEFT, fill=tk.Y)
        
        nav_buttons = [
            ("📊 Dashboard", self.show_dashboard),
            ("👥 Citizens", self.show_citizens),
            ("📄 Applications", self.show_applications),
            ("🎫 Permit Types", self.show_permit_types),
            ("🏢 Departments", self.show_departments),
            ("📜 Licenses", self.show_licenses),
            ("✅ Review Steps", self.show_review_steps),
            ("📎 Documents", self.show_documents),
            ("📅 Holidays", self.show_holidays),
            ("🔍 Audit Logs", self.show_audit_logs),
        ]
        
        for text, command in nav_buttons:
            btn = tk.Button(
                self.sidebar, text=text, command=command,
                bg='#34495e', fg='white', font=('Arial', 10, 'bold'),
                relief=tk.FLAT, padx=15, pady=12, anchor='w'
            )
            btn.pack(fill=tk.X, pady=1)
        
        self.content_frame = tk.Frame(self.root, bg='white')
        self.content_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
    
    def clear_content(self):
        for widget in self.content_frame.winfo_children():
            widget.destroy()
    
    def show_dashboard(self):
        self.clear_content()
        
        header = tk.Frame(self.content_frame, bg='#3498db', height=80)
        header.pack(fill=tk.X)
        
        tk.Label(
            header, text="📊 Dashboard", 
            font=('Arial', 28, 'bold'), bg='#3498db', fg='white'
        ).pack(pady=20)
        
        stats_container = tk.Frame(self.content_frame, bg='white')
        stats_container.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        stats = self.get_dashboard_stats()
        
        row, col = 0, 0
        for label, value, color in stats:
            card = tk.Frame(stats_container, bg=color, relief=tk.RAISED, bd=3)
            card.grid(row=row, column=col, padx=15, pady=15, sticky='nsew', ipadx=20, ipady=20)
            
            tk.Label(card, text=label, font=('Arial', 11, 'bold'), 
                    bg=color, fg='white').pack(pady=8)
            tk.Label(card, text=str(value), font=('Arial', 24, 'bold'), 
                    bg=color, fg='white').pack(pady=8)
            
            col += 1
            if col > 2:
                col, row = 0, row + 1
        
        for i in range(3):
            stats_container.columnconfigure(i, weight=1)
            stats_container.rowconfigure(i, weight=1)
    
    def get_dashboard_stats(self):
        stats = []
        
        result = self.db.execute_query("SELECT COUNT(*) FROM CITIZEN WHERE status = 'Active'")
        stats.append(("Active Citizens", result[0][0] if result else 0, '#3498db'))
        
        result = self.db.execute_query("SELECT COUNT(*) FROM APPLICATION")
        stats.append(("Total Applications", result[0][0] if result else 0, '#2ecc71'))
        
        result = self.db.execute_query(
            "SELECT COUNT(*) FROM APPLICATION WHERE status IN ('Submitted', 'Under Review')"
        )
        stats.append(("Pending Reviews", result[0][0] if result else 0, '#f39c12'))
        
        result = self.db.execute_query(
            "SELECT COUNT(*) FROM ISSUED_LICENSE WHERE license_status = 'Active'"
        )
        stats.append(("Active Licenses", result[0][0] if result else 0, '#9b59b6'))
        
        result = self.db.execute_query(
            "SELECT NVL(SUM(payment_amount), 0) FROM APPLICATION WHERE payment_status = 'Paid'"
        )
        stats.append(("Total Revenue (RWF)", f"{result[0][0]:,.0f}" if result else 0, '#e74c3c'))
        
        result = self.db.execute_query("SELECT COUNT(*) FROM PERMIT_TYPE WHERE is_active = 'Y'")
        stats.append(("Permit Types", result[0][0] if result else 0, '#1abc9c'))
        
        result = self.db.execute_query("SELECT COUNT(*) FROM DEPARTMENT WHERE is_active = 'Y'")
        stats.append(("Departments", result[0][0] if result else 0, '#34495e'))
        
        result = self.db.execute_query("SELECT COUNT(*) FROM AUDIT_LOG")
        stats.append(("Audit Records", result[0][0] if result else 0, '#95a5a6'))
        
        return stats
    
    def show_citizens(self):
        self.clear_content()
        self.create_data_view("Citizens Management", {
            'columns': ['ID', 'Name', 'National ID', 'Email', 'Phone', 'DOB', 'Residency', 'Status'],
            'query': """
                SELECT citizen_id, first_name || ' ' || last_name, national_id, 
                       email, phone, TO_CHAR(date_of_birth, 'YYYY-MM-DD'), 
                       residency_status, status
                FROM CITIZEN ORDER BY citizen_id DESC
            """,
            'actions': [
                ('Register New', self.show_register_citizen),
                ('Calculate Age', lambda t: self.calculate_age(t)),
                ('Check Eligibility', lambda t: self.check_eligibility(t))
            ]
        })
    
    def show_applications(self):
        self.clear_content()
        self.create_data_view("Applications Management", {
            'columns': ['ID', 'App #', 'Citizen', 'Permit', 'Status', 'Priority', 'Payment', 'Amount', 'Date'],
            'query': """
                SELECT a.application_id, a.application_number,
                       c.first_name || ' ' || c.last_name, pt.permit_name, 
                       a.status, a.priority_level, a.payment_status, 
                       a.payment_amount, TO_CHAR(a.submission_date, 'YYYY-MM-DD')
                FROM APPLICATION a
                JOIN CITIZEN c ON a.citizen_id = c.citizen_id
                JOIN PERMIT_TYPE pt ON a.permit_type_id = pt.permit_type_id
                ORDER BY a.application_id DESC
            """,
            'actions': [
                ('Submit New', self.show_submit_application),
                ('View Summary', lambda t: self.view_summary(t)),
                ('Process Payment', lambda t: self.process_payment(t))
            ]
        })
    
    def show_permit_types(self):
        self.clear_content()
        self.create_data_view("Permit Types", {
            'columns': ['ID', 'Name', 'Category', 'Fee (RWF)', 'Validity', 'Est. Days', 'Active'],
            'query': """
                SELECT permit_type_id, permit_name, category, processing_fee,
                       validity_period, estimated_days, is_active
                FROM PERMIT_TYPE ORDER BY permit_name
            """,
            'actions': [('Get Details', lambda t: self.get_permit_details(t))]
        })
    
    def show_departments(self):
        self.clear_content()
        self.create_data_view("Departments", {
            'columns': ['ID', 'Name', 'Code', 'Head Officer', 'Email', 'Active'],
            'query': """
                SELECT department_id, department_name, department_code,
                       head_officer, contact_email, is_active
                FROM DEPARTMENT ORDER BY department_name
            """,
            'actions': [('Pending Reviews', lambda t: self.count_pending_reviews(t))]
        })
    
    def show_licenses(self):
        self.clear_content()
        self.create_data_view("Issued Licenses", {
            'columns': ['ID', 'License #', 'App #', 'Issued', 'Expires', 'Status', 'Renewable'],
            'query': """
                SELECT l.license_id, l.license_number, a.application_number,
                       TO_CHAR(l.issue_date, 'YYYY-MM-DD'),
                       TO_CHAR(l.expiration_date, 'YYYY-MM-DD'),
                       l.license_status, l.renewal_eligible
                FROM ISSUED_LICENSE l
                JOIN APPLICATION a ON l.application_id = a.application_id
                ORDER BY l.license_id DESC
            """,
            'actions': [('Calculate Renewal Fee', lambda t: self.calc_renewal_fee(t))]
        })
    
    def show_review_steps(self):
        self.clear_content()
        self.create_data_view("Review Steps", {
            'columns': ['ID', 'App ID', 'Dept', 'Step#', 'Status', 'Reviewer', 'Decision', 'Date'],
            'query': """
                SELECT r.step_id, r.application_id, d.department_name, r.step_number,
                       r.step_status, r.reviewer_name, r.decision,
                       TO_CHAR(r.review_date, 'YYYY-MM-DD')
                FROM REVIEW_STEP r
                JOIN DEPARTMENT d ON r.department_id = d.department_id
                ORDER BY r.step_id DESC
            """,
            'actions': [
                ('Add Review', self.show_add_review),
                ('Complete Step', lambda t: self.complete_review(t))
            ]
        })
    
    def show_documents(self):
        self.clear_content()
        self.create_data_view("Documents", {
            'columns': ['ID', 'App ID', 'Type', 'File Name', 'Size (KB)', 'Date', 'Verified'],
            'query': """
                SELECT document_id, application_id, document_type, file_name,
                       ROUND(file_size/1024, 2), TO_CHAR(upload_date, 'YYYY-MM-DD'), verified
                FROM DOCUMENT ORDER BY document_id DESC
            """,
            'actions': []
        })
    
    def show_holidays(self):
        self.clear_content()
        self.create_data_view("Public Holidays", {
            'columns': ['ID', 'Holiday Name', 'Date', 'Type'],
            'query': """
                SELECT holiday_id, holiday_name, TO_CHAR(holiday_date, 'YYYY-MM-DD'), holiday_type
                FROM HOLIDAYS ORDER BY holiday_date
            """,
            'actions': []
        })
    
    def show_audit_logs(self):
        self.clear_content()
        self.create_data_view("Audit Logs", {
            'columns': ['ID', 'Table', 'Operation', 'Date', 'User', 'Status', 'Record ID'],
            'query': """
                SELECT audit_id, table_name, operation_type,
                       TO_CHAR(operation_date, 'YYYY-MM-DD HH24:MI:SS'),
                       username, status, record_id
                FROM AUDIT_LOG ORDER BY audit_id DESC FETCH FIRST 500 ROWS ONLY
            """,
            'actions': [
                ('Export CSV', lambda t: self.export_audit_logs()),
                ('Export JSON', lambda t: self.export_audit_json())
            ]
        })
    
    def create_data_view(self, title, config):
        header = tk.Frame(self.content_frame, bg='#34495e', height=60)
        header.pack(fill=tk.X)
        tk.Label(header, text=title, font=('Arial', 20, 'bold'), 
                bg='#34495e', fg='white').pack(pady=15)
        
        control_frame = tk.Frame(self.content_frame, bg='#ecf0f1')
        control_frame.pack(fill=tk.X, padx=10, pady=10)
        
        for btn_text, btn_cmd in config.get('actions', []):
            tk.Button(control_frame, text=btn_text, command=btn_cmd,
                     bg='#3498db', fg='white', font=('Arial', 9, 'bold'),
                     padx=10, pady=5).pack(side=tk.LEFT, padx=5)
        
        tk.Button(control_frame, text='🔄 Refresh', 
                 command=lambda: self.create_data_view(title, config),
                 bg='#95a5a6', fg='white', font=('Arial', 9, 'bold'),
                 padx=10, pady=5).pack(side=tk.LEFT, padx=5)
        
        tree_frame = tk.Frame(self.content_frame)
        tree_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        vsb = ttk.Scrollbar(tree_frame, orient="vertical")
        hsb = ttk.Scrollbar(tree_frame, orient="horizontal")
        
        tree = ttk.Treeview(tree_frame, columns=config['columns'], show='headings',
                           yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        
        vsb.config(command=tree.yview)
        hsb.config(command=tree.xview)
        
        for col in config['columns']:
            tree.heading(col, text=col)
            tree.column(col, width=100)
        
        tree.grid(row=0, column=0, sticky='nsew')
        vsb.grid(row=0, column=1, sticky='ns')
        hsb.grid(row=1, column=0, sticky='ew')
        
        tree_frame.grid_rowconfigure(0, weight=1)
        tree_frame.grid_columnconfigure(0, weight=1)
        
        results = self.db.execute_query(config['query'])
        for row in results:
            tree.insert('', tk.END, values=row)
        
        config['tree'] = tree
    
    # ============ FIXED EXPORT METHODS ============
    
    def export_audit_logs(self):
        """Export audit logs to CSV - FIXED"""
        try:
            cursor = self.db.connection.cursor()
            refcursor = cursor.var(oracledb.CURSOR)
            cursor.callproc('sp_export_audit_log', [None, None, None, None, refcursor])
            
            result_cursor = refcursor.getvalue()
            results = result_cursor.fetchall()
            result_cursor.close()
            cursor.close()
            
            if not results:
                messagebox.showinfo("No Data", "No audit logs found")
                return
            
            filename = filedialog.asksaveasfilename(
                defaultextension=".csv",
                filetypes=[("CSV files", "*.csv"), ("All files", "*.*")]
            )
            
            if filename:
                with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
                    writer = csv.writer(csvfile)
                    writer.writerow(['ID', 'Table', 'Operation', 'Date', 'Time', 'User', 
                                   'Status', 'Reason', 'Record ID', 'Old Values', 'New Values'])
                    
                    for row in results:
                        processed_row = [safe_convert(cell) for cell in row]
                        writer.writerow(processed_row)
                
                messagebox.showinfo("Success", f"Exported to {filename}")
                
        except Exception as e:
            messagebox.showerror("Error", f"Export failed: {str(e)}")
    
    def export_audit_json(self):
        """Export audit logs to JSON - FIXED"""
        try:
            cursor = self.db.connection.cursor()
            refcursor = cursor.var(oracledb.CURSOR)
            cursor.callproc('sp_export_audit_log', [None, None, None, None, refcursor])
            
            result_cursor = refcursor.getvalue()
            results = result_cursor.fetchall()
            result_cursor.close()
            cursor.close()
            
            if not results:
                messagebox.showinfo("No Data", "No audit logs found")
                return
            
            filename = filedialog.asksaveasfilename(
                defaultextension=".json",
                filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
            )
            
            if filename:
                audit_data = []
                for row in results:
                    audit_data.append({
                        'id': int(row[0]) if row[0] is not None else None,
                        'table': safe_convert(row[1]),
                        'operation': safe_convert(row[2]),
                        'date': safe_convert(row[3])[:10] if row[3] else None,
                        'time': safe_convert(row[4]),
                        'user': safe_convert(row[5]),
                        'status': safe_convert(row[6]),
                        'reason': safe_convert(row[7]),
                        'record_id': int(row[8]) if row[8] is not None else None,
                        'old_values': safe_convert(row[9]),
                        'new_values': safe_convert(row[10])
                    })
                
                with open(filename, 'w', encoding='utf-8') as jsonfile:
                    json.dump(audit_data, jsonfile, indent=2)
                
                messagebox.showinfo("Success", f"Exported to {filename}")
                
        except Exception as e:
            messagebox.showerror("Error", f"Export failed: {str(e)}")
    
    def export_all_data(self):
        """Export all data to CSV - FIXED"""
        folder = filedialog.askdirectory(title="Select folder")
        if not folder:
            return
        
        tables = [
            ('CITIZEN', 'citizens.csv'),
            ('APPLICATION', 'applications.csv'),
            ('PERMIT_TYPE', 'permit_types.csv'),
            ('DEPARTMENT', 'departments.csv'),
            ('ISSUED_LICENSE', 'licenses.csv'),
            ('REVIEW_STEP', 'review_steps.csv'),
            ('DOCUMENT', 'documents.csv'),
            ('HOLIDAYS', 'holidays.csv'),
            ('AUDIT_LOG', 'audit_logs.csv')
        ]
        
        exported = 0
        failed = []
        
        for table, filename in tables:
            try:
                cursor = self.db.connection.cursor()
                cursor.execute(f"SELECT * FROM {table}")
                results = cursor.fetchall()
                columns = [desc[0] for desc in cursor.description]
                cursor.close()
                
                filepath = f"{folder}/{filename}"
                with open(filepath, 'w', newline='', encoding='utf-8') as csvfile:
                    writer = csv.writer(csvfile)
                    writer.writerow(columns)
                    
                    for row in results:
                        processed_row = [safe_convert(cell) for cell in row]
                        writer.writerow(processed_row)
                
                exported += 1
                
            except Exception as e:
                failed.append(f"{table}: {str(e)}")
        
        summary = f"Exported {exported}/{len(tables)} tables"
        if failed:
            summary += "\n\nFailed:\n" + "\n".join(failed)
            messagebox.showwarning("Export Complete", summary)
        else:
            messagebox.showinfo("Success", summary)
    
    # ============ FIXED DIALOG METHODS ============
    
    def show_register_citizen(self):
        dialog = tk.Toplevel(self.root)
        dialog.title("Register New Citizen")
        dialog.geometry("500x550")
        dialog.transient(self.root)
        dialog.grab_set()
        
        fields = [
            ('First Name', 'first_name'),
            ('Last Name', 'last_name'),
            ('Date of Birth (YYYY-MM-DD)', 'dob'),
            ('National ID', 'national_id'),
            ('Email', 'email'),
            ('Phone', 'phone'),
            ('Address', 'address'),
        ]
        
        entries = {}
        for i, (label, key) in enumerate(fields):
            tk.Label(dialog, text=label + ":").grid(row=i, column=0, sticky='w', padx=20, pady=8)
            entry = tk.Entry(dialog, width=35)
            entry.grid(row=i, column=1, padx=20, pady=8)
            entries[key] = entry
        
        tk.Label(dialog, text="Residency:").grid(row=len(fields), column=0, sticky='w', padx=20, pady=8)
        residency_var = tk.StringVar(value='Citizen')
        residency_combo = ttk.Combobox(dialog, textvariable=residency_var, 
                                      values=['Citizen', 'Resident', 'Foreigner'], width=33)
        residency_combo.grid(row=len(fields), column=1, padx=20, pady=8)
        
        def register():
            for key, entry in entries.items():
                if not entry.get().strip():
                    messagebox.showerror("Error", f"Please fill {key}")
                    return
            
            try:
                cursor = self.db.connection.cursor()
                citizen_id_var = cursor.var(oracledb.NUMBER)
                
                cursor.callproc('sp_register_citizen', [
                    entries['first_name'].get(),
                    entries['last_name'].get(),
                    datetime.strptime(entries['dob'].get(), '%Y-%m-%d'),
                    entries['national_id'].get(),
                    entries['email'].get(),
                    entries['phone'].get(),
                    entries['address'].get(),
                    residency_var.get(),
                    citizen_id_var
                ])
                
                self.db.connection.commit()
                citizen_id_value = citizen_id_var.getvalue()
                cursor.close()
                
                messagebox.showinfo("Success", f"Citizen registered! ID: {citizen_id_value}")
                dialog.destroy()
                self.show_citizens()
                
            except oracledb.Error as e:
                messagebox.showerror("Error", str(e))
            except Exception as e:
                messagebox.showerror("Error", str(e))
        
        btn_frame = tk.Frame(dialog)
        btn_frame.grid(row=len(fields)+1, column=0, columnspan=2, pady=20)
        
        tk.Button(btn_frame, text="Register", command=register, 
                 bg='#2ecc71', fg='white', width=15, font=('Arial', 10, 'bold')).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Cancel", command=dialog.destroy, 
                 bg='#e74c3c', fg='white', width=15, font=('Arial', 10, 'bold')).pack(side=tk.LEFT, padx=5)
    
    def show_submit_application(self):
        dialog = tk.Toplevel(self.root)
        dialog.title("Submit New Application")
        dialog.geometry("550x400")
        dialog.transient(self.root)
        dialog.grab_set()
        
        citizens = self.db.execute_query(
            "SELECT citizen_id, first_name || ' ' || last_name FROM CITIZEN WHERE status = 'Active'"
        )
        permits = self.db.execute_query(
            "SELECT permit_type_id, permit_name FROM PERMIT_TYPE WHERE is_active = 'Y'"
        )
        
        tk.Label(dialog, text="Citizen:", font=('Arial', 10)).grid(row=0, column=0, sticky='w', padx=20, pady=10)
        citizen_var = tk.StringVar()
        citizen_combo = ttk.Combobox(dialog, textvariable=citizen_var, width=45)
        citizen_combo['values'] = [f"{c[0]}: {c[1]}" for c in citizens]
        citizen_combo.grid(row=0, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Permit Type:", font=('Arial', 10)).grid(row=1, column=0, sticky='w', padx=20, pady=10)
        permit_var = tk.StringVar()
        permit_combo = ttk.Combobox(dialog, textvariable=permit_var, width=45)
        permit_combo['values'] = [f"{p[0]}: {p[1]}" for p in permits]
        permit_combo.grid(row=1, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Priority:", font=('Arial', 10)).grid(row=2, column=0, sticky='w', padx=20, pady=10)
        priority_var = tk.StringVar(value='Normal')
        ttk.Combobox(dialog, textvariable=priority_var, 
                    values=['Low', 'Normal', 'High', 'Urgent'], width=45).grid(row=2, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Notes:", font=('Arial', 10)).grid(row=3, column=0, sticky='nw', padx=20, pady=10)
        notes_text = tk.Text(dialog, width=45, height=5)
        notes_text.grid(row=3, column=1, padx=20, pady=10)
        
        def submit():
            if not citizen_var.get() or not permit_var.get():
                messagebox.showerror("Error", "Select citizen and permit type")
                return
            
            try:
                cid = int(citizen_var.get().split(':')[0])
                pid = int(permit_var.get().split(':')[0])
                
                cursor = self.db.connection.cursor()
                app_id_var = cursor.var(oracledb.NUMBER)
                
                cursor.callproc('sp_submit_application', [
                    cid, pid, priority_var.get(),
                    notes_text.get('1.0', tk.END).strip() or None,
                    app_id_var
                ])
                
                self.db.connection.commit()
                app_id_value = app_id_var.getvalue()
                cursor.close()
                
                messagebox.showinfo("Success", f"Application submitted! ID: {app_id_value}")
                dialog.destroy()
                self.show_applications()
                
            except oracledb.Error as e:
                messagebox.showerror("Error", str(e))
            except Exception as e:
                messagebox.showerror("Error", str(e))
        
        btn_frame = tk.Frame(dialog)
        btn_frame.grid(row=4, column=0, columnspan=2, pady=20)
        
        tk.Button(btn_frame, text="Submit", command=submit, 
                 bg='#3498db', fg='white', width=15).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Cancel", command=dialog.destroy, 
                 bg='#95a5a6', fg='white', width=15).pack(side=tk.LEFT, padx=5)
    
    def show_process_payment(self):
        dialog = tk.Toplevel(self.root)
        dialog.title("Process Payment")
        dialog.geometry("450x300")
        
        tk.Label(dialog, text="Application ID:").grid(row=0, column=0, padx=20, pady=10)
        app_id = tk.Entry(dialog, width=30)
        app_id.grid(row=0, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Payment Amount:").grid(row=1, column=0, padx=20, pady=10)
        amount = tk.Entry(dialog, width=30)
        amount.grid(row=1, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Payment Method:").grid(row=2, column=0, padx=20, pady=10)
        method_var = tk.StringVar(value='Cash')
        ttk.Combobox(dialog, textvariable=method_var, 
                    values=['Cash', 'Mobile Money', 'Bank Transfer'], 
                    width=28).grid(row=2, column=1, padx=20, pady=10)
        
        def process():
            try:
                cursor = self.db.connection.cursor()
                cursor.callproc('sp_process_payment', [
                    int(app_id.get()),
                    float(amount.get()),
                    method_var.get()
                ])
                self.db.connection.commit()
                cursor.close()
                messagebox.showinfo("Success", "Payment processed!")
                dialog.destroy()
            except Exception as e:
                messagebox.showerror("Error", str(e))
        
        tk.Button(dialog, text="Process", command=process, bg='#2ecc71', fg='white', width=15).grid(row=3, column=0, columnspan=2, pady=20)
    
    def show_add_review(self):
        dialog = tk.Toplevel(self.root)
        dialog.title("Add Review Step")
        dialog.geometry("500x350")
        
        depts = self.db.execute_query("SELECT department_id, department_name FROM DEPARTMENT WHERE is_active = 'Y'")
        
        tk.Label(dialog, text="Application ID:").grid(row=0, column=0, padx=20, pady=10)
        app_id = tk.Entry(dialog, width=30)
        app_id.grid(row=0, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Department:").grid(row=1, column=0, padx=20, pady=10)
        dept_var = tk.StringVar()
        dept_combo = ttk.Combobox(dialog, textvariable=dept_var, width=28)
        dept_combo['values'] = [f"{d[0]}: {d[1]}" for d in depts]
        dept_combo.grid(row=1, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Reviewer Name:").grid(row=2, column=0, padx=20, pady=10)
        reviewer = tk.Entry(dialog, width=30)
        reviewer.grid(row=2, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Comments:").grid(row=3, column=0, padx=20, pady=10, sticky='nw')
        comments = tk.Text(dialog, width=30, height=4)
        comments.grid(row=3, column=1, padx=20, pady=10)
        
        def add():
            try:
                cursor = self.db.connection.cursor()
                cursor.callproc('sp_add_review_step', [
                    int(app_id.get()),
                    int(dept_var.get().split(':')[0]),
                    reviewer.get(),
                    comments.get('1.0', tk.END).strip()
                ])
                self.db.connection.commit()
                cursor.close()
                messagebox.showinfo("Success", "Review step added!")
                dialog.destroy()
            except Exception as e:
                messagebox.showerror("Error", str(e))
        
        tk.Button(dialog, text="Add", command=add, bg='#3498db', fg='white', width=15).grid(row=4, column=0, columnspan=2, pady=20)
    
    # ============ REPORT & ACTION METHODS ============
    
    def check_operation_allowed(self):
        try:
            cursor = self.db.connection.cursor()
            result = cursor.callfunc('check_operation_allowed', oracledb.STRING, [])
            cursor.close()
            messagebox.showinfo("Operation Check", result)
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    def show_bulk_update(self):
        dialog = tk.Toplevel(self.root)
        dialog.title("Bulk Update Application Status")
        dialog.geometry("450x300")
        
        tk.Label(dialog, text="Old Status:").grid(row=0, column=0, padx=20, pady=10)
        old_status_var = tk.StringVar(value='Submitted')
        ttk.Combobox(dialog, textvariable=old_status_var, 
                    values=['Submitted', 'Under Review', 'Documentation Required', 
                           'On Hold', 'Cancelled'], width=25).grid(row=0, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="New Status:").grid(row=1, column=0, padx=20, pady=10)
        new_status_var = tk.StringVar(value='Cancelled')
        ttk.Combobox(dialog, textvariable=new_status_var, 
                    values=['Submitted', 'Under Review', 'Documentation Required', 
                           'Approved', 'Rejected', 'Cancelled', 'On Hold'], width=25).grid(row=1, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Days in Status:").grid(row=2, column=0, padx=20, pady=10)
        days_entry = tk.Entry(dialog, width=30)
        days_entry.insert(0, "30")
        days_entry.grid(row=2, column=1, padx=20, pady=10)
        
        def update():
            try:
                cursor = self.db.connection.cursor()
                count_updated = cursor.var(oracledb.NUMBER)
                
                cursor.callproc('sp_bulk_update_status', [
                    old_status_var.get(),
                    new_status_var.get(),
                    int(days_entry.get()),
                    count_updated
                ])
                
                self.db.connection.commit()
                count_value = count_updated.getvalue()
                cursor.close()
                
                messagebox.showinfo("Success", f"Updated {count_value} applications")
                dialog.destroy()
                
            except Exception as e:
                messagebox.showerror("Error", str(e))
        
        tk.Button(dialog, text="Bulk Update", command=update, 
                 bg='#f39c12', fg='white', width=15).grid(row=3, column=0, columnspan=2, pady=20)
    
    def show_monthly_revenue(self):
        self.clear_content()
        
        header = tk.Frame(self.content_frame, bg='#2c3e50', height=60)
        header.pack(fill=tk.X)
        tk.Label(header, text="📈 Monthly Revenue Report", font=('Arial', 20, 'bold'), 
                bg='#2c3e50', fg='white').pack(pady=15)
        
        control_frame = tk.Frame(self.content_frame, bg='#ecf0f1')
        control_frame.pack(fill=tk.X, padx=10, pady=10)
        
        tk.Label(control_frame, text="Year:").pack(side=tk.LEFT, padx=5)
        year_var = tk.StringVar(value=str(datetime.now().year))
        year_combo = ttk.Combobox(control_frame, textvariable=year_var, 
                                 values=[str(i) for i in range(2020, 2031)], width=10)
        year_combo.pack(side=tk.LEFT, padx=5)
        
        report_frame = tk.Frame(self.content_frame, bg='white')
        report_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        def load_report():
            try:
                # Try direct SELECT first
                query = f"""
                SELECT 
                    TO_CHAR(submission_date, 'YYYY-MM') as month,
                    SUM(payment_amount) as revenue,
                    COUNT(*) as app_count
                FROM APPLICATION
                WHERE TO_CHAR(submission_date, 'YYYY') = '{year_var.get()}'
                    AND payment_status = 'Paid'
                GROUP BY TO_CHAR(submission_date, 'YYYY-MM')
                ORDER BY month
                """
                
                results = self.db.execute_query(query)
                
                for widget in report_frame.winfo_children():
                    widget.destroy()
                
                if not results:
                    tk.Label(report_frame, text="No data found", 
                            font=('Arial', 12)).pack(pady=20)
                    return
                
                tree_frame = tk.Frame(report_frame)
                tree_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
                
                vsb = ttk.Scrollbar(tree_frame, orient="vertical")
                tree = ttk.Treeview(tree_frame, columns=('Month', 'Revenue', 'Applications'), 
                                  show='headings', yscrollcommand=vsb.set)
                
                tree.heading('Month', text='Month')
                tree.heading('Revenue', text='Revenue (RWF)')
                tree.heading('Applications', text='Applications')
                
                total_revenue = 0
                total_apps = 0
                for month, revenue, apps in results:
                    revenue_val = float(revenue) if revenue else 0
                    apps_val = int(apps) if apps else 0
                    tree.insert('', tk.END, values=(month, f"{revenue_val:,.0f}", apps_val))
                    total_revenue += revenue_val
                    total_apps += apps_val
                
                tree.grid(row=0, column=0, sticky='nsew')
                vsb.grid(row=0, column=1, sticky='ns')
                vsb.config(command=tree.yview)
                
                tree_frame.grid_rowconfigure(0, weight=1)
                tree_frame.grid_columnconfigure(0, weight=1)
                
                summary = tk.Label(report_frame, 
                                 text=f"Total Revenue: {total_revenue:,.0f} RWF | Total Applications: {total_apps}",
                                 font=('Arial', 12, 'bold'), bg='#ecf0f1')
                summary.pack(pady=5)
                
            except Exception as e:
                messagebox.showerror("Error", f"Failed to load report: {str(e)}")
        
        tk.Button(control_frame, text="Load Report", command=load_report, 
                 bg='#3498db', fg='white').pack(side=tk.LEFT, padx=10)
        
        load_report()
    
    def show_dept_performance(self):
        self.clear_content()
        
        header = tk.Frame(self.content_frame, bg='#2c3e50', height=60)
        header.pack(fill=tk.X)
        tk.Label(header, text="📊 Department Performance", font=('Arial', 20, 'bold'), 
                bg='#2c3e50', fg='white').pack(pady=15)
        
        depts = self.db.execute_query(
            "SELECT department_id, department_name FROM DEPARTMENT WHERE is_active = 'Y' ORDER BY department_name"
        )
        
        if not depts:
            tk.Label(self.content_frame, text="No active departments found", 
                    font=('Arial', 12)).pack(pady=20)
            return
        
        tree_frame = tk.Frame(self.content_frame)
        tree_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        vsb = ttk.Scrollbar(tree_frame, orient="vertical")
        tree = ttk.Treeview(tree_frame, columns=('ID', 'Department', 'Performance Score', 'Pending Reviews'), 
                          show='headings', yscrollcommand=vsb.set)
        
        tree.heading('ID', text='ID')
        tree.heading('Department', text='Department')
        tree.heading('Performance Score', text='Performance Score')
        tree.heading('Pending Reviews', text='Pending Reviews')
        
        tree.column('ID', width=50)
        tree.column('Department', width=200)
        tree.column('Performance Score', width=150)
        tree.column('Pending Reviews', width=120)
        
        for dept_id, dept_name in depts:
            try:
                cursor = self.db.connection.cursor()
                score = cursor.callfunc('pkg_analytics.get_department_performance', 
                                       oracledb.NUMBER, [dept_id])
                cursor.close()
                
                pending = self.db.execute_query(
                    f"SELECT fn_count_pending_reviews({dept_id}) FROM dual"
                )[0][0]
                
                tree.insert('', tk.END, values=(dept_id, dept_name, 
                                              f"{score:.2f}%" if score else "N/A", 
                                              pending if pending else 0))
                
            except Exception:
                tree.insert('', tk.END, values=(dept_id, dept_name, "Error", "N/A"))
        
        tree.grid(row=0, column=0, sticky='nsew')
        vsb.grid(row=0, column=1, sticky='ns')
        vsb.config(command=tree.yview)
        
        tree_frame.grid_rowconfigure(0, weight=1)
        tree_frame.grid_columnconfigure(0, weight=1)
    
    def show_top_permits(self):
        self.clear_content()
        
        header = tk.Frame(self.content_frame, bg='#2c3e50', height=60)
        header.pack(fill=tk.X)
        tk.Label(header, text="🏆 Top Permit Types", font=('Arial', 20, 'bold'), 
                bg='#2c3e50', fg='white').pack(pady=15)
        
        try:
            cursor = self.db.connection.cursor()
            refcursor = cursor.callfunc('pkg_analytics.get_top_permit_types', 
                                       oracledb.CURSOR, [5])
            
            results = refcursor.fetchall()
            cursor.close()
            
            if not results:
                tk.Label(self.content_frame, text="No permit data available", 
                        font=('Arial', 12)).pack(pady=20)
                return
            
            tree_frame = tk.Frame(self.content_frame)
            tree_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
            
            vsb = ttk.Scrollbar(tree_frame, orient="vertical")
            tree = ttk.Treeview(tree_frame, 
                              columns=('Permit', 'Total Apps', 'Approved', 'Avg Fee', 'First App', 'Last App'), 
                              show='headings', yscrollcommand=vsb.set)
            
            tree.heading('Permit', text='Permit Type')
            tree.heading('Total Apps', text='Total Applications')
            tree.heading('Approved', text='Approved')
            tree.heading('Avg Fee', text='Average Fee')
            tree.heading('First App', text='First Application')
            tree.heading('Last App', text='Last Application')
            
            for permit, total, approved, avg_fee, first_app, last_app in results:
                tree.insert('', tk.END, values=(
                    permit,
                    total or 0,
                    approved or 0,
                    f"{avg_fee or 0:,.0f} RWF" if avg_fee else "N/A",
                    first_app.strftime('%Y-%m-%d') if first_app else "N/A",
                    last_app.strftime('%Y-%m-%d') if last_app else "N/A"
                ))
            
            tree.grid(row=0, column=0, sticky='nsew')
            vsb.grid(row=0, column=1, sticky='ns')
            vsb.config(command=tree.yview)
            
            tree_frame.grid_rowconfigure(0, weight=1)
            tree_frame.grid_columnconfigure(0, weight=1)
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load report: {str(e)}")
    
    def calculate_revenue(self):
        dialog = tk.Toplevel(self.root)
        dialog.title("Calculate Revenue")
        dialog.geometry("400x250")
        
        tk.Label(dialog, text="Start Date (YYYY-MM-DD):").grid(row=0, column=0, padx=20, pady=10)
        start_date = tk.Entry(dialog, width=25)
        start_date.grid(row=0, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="End Date (YYYY-MM-DD):").grid(row=1, column=0, padx=20, pady=10)
        end_date = tk.Entry(dialog, width=25)
        end_date.grid(row=1, column=1, padx=20, pady=10)
        
        tk.Label(dialog, text="Permit Type ID (optional):").grid(row=2, column=0, padx=20, pady=10)
        permit_id = tk.Entry(dialog, width=25)
        permit_id.grid(row=2, column=1, padx=20, pady=10)
        
        def calculate():
            try:
                cursor = self.db.connection.cursor()
                
                start = datetime.strptime(start_date.get(), '%Y-%m-%d') if start_date.get() else None
                end = datetime.strptime(end_date.get(), '%Y-%m-%d') if end_date.get() else None
                permit = int(permit_id.get()) if permit_id.get() else None
                
                revenue = cursor.callfunc('fn_calculate_revenue', oracledb.NUMBER, 
                                         [start, end, permit])
                cursor.close()
                
                messagebox.showinfo("Revenue Calculation", 
                                  f"Total Revenue: {revenue:,.0f} RWF")
                dialog.destroy()
                
            except Exception as e:
                messagebox.showerror("Error", str(e))
        
        tk.Button(dialog, text="Calculate", command=calculate, 
                 bg='#2ecc71', fg='white', width=15).grid(row=3, column=0, columnspan=2, pady=20)
    
    # ============ HELPER METHODS ============
    
    def calculate_age(self, tree):
        selection = tree.selection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select a citizen first")
            return
        
        citizen_id = tree.item(selection[0])['values'][0]
        try:
            cursor = self.db.connection.cursor()
            age = cursor.callfunc('fn_calculate_citizen_age', oracledb.NUMBER, [citizen_id])
            cursor.close()
            
            messagebox.showinfo("Age Calculation", f"Citizen ID {citizen_id} is {age} years old")
            
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    def check_eligibility(self, tree):
        selection = tree.selection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select a citizen first")
            return
        
        citizen_id = tree.item(selection[0])['values'][0]
        
        dialog = tk.Toplevel(self.root)
        dialog.title("Check Eligibility")
        dialog.geometry("300x150")
        
        tk.Label(dialog, text="Select Permit Type:").pack(pady=10)
        
        permits = self.db.execute_query(
            "SELECT permit_type_id, permit_name FROM PERMIT_TYPE WHERE is_active = 'Y'"
        )
        
        permit_var = tk.StringVar()
        permit_combo = ttk.Combobox(dialog, textvariable=permit_var, width=30)
        permit_combo['values'] = [f"{p[0]}: {p[1]}" for p in permits]
        permit_combo.pack(pady=10)
        
        def check():
            if not permit_var.get():
                messagebox.showerror("Error", "Please select a permit type")
                return
            
            try:
                permit_id = int(permit_var.get().split(':')[0])
                cursor = self.db.connection.cursor()
                result = cursor.callfunc('fn_validate_eligibility', oracledb.STRING, 
                                        [citizen_id, permit_id])
                cursor.close()
                
                messagebox.showinfo("Eligibility Check", result)
                dialog.destroy()
                
            except Exception as e:
                messagebox.showerror("Error", str(e))
        
        tk.Button(dialog, text="Check", command=check, 
                 bg='#3498db', fg='white').pack(pady=10)
    
    def view_summary(self, tree):
        selection = tree.selection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select an application first")
            return
        
        app_id = tree.item(selection[0])['values'][0]
        try:
            cursor = self.db.connection.cursor()
            summary = cursor.callfunc('fn_get_app_status_summary', oracledb.STRING, [app_id])
            cursor.close()
            
            messagebox.showinfo("Application Summary", summary)
            
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    def process_payment(self, tree):
        selection = tree.selection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select an application first")
            return
        
        app_id = tree.item(selection[0])['values'][0]
        
        result = self.db.execute_query(
            f"SELECT payment_amount FROM APPLICATION WHERE application_id = {app_id}"
        )
        
        if not result:
            messagebox.showerror("Error", "Application not found")
            return
        
        fee = result[0][0]
        
        dialog = tk.Toplevel(self.root)
        dialog.title(f"Process Payment - App {app_id}")
        dialog.geometry("400x200")
        
        tk.Label(dialog, text=f"Application ID: {app_id}").pack(pady=5)
        tk.Label(dialog, text=f"Required Fee: {fee:,.0f} RWF", 
                font=('Arial', 11, 'bold')).pack(pady=5)
        
        tk.Label(dialog, text="Payment Amount:").pack(pady=5)
        amount_entry = tk.Entry(dialog, width=30)
        amount_entry.insert(0, str(fee))
        amount_entry.pack(pady=5)
        
        tk.Label(dialog, text="Payment Method:").pack(pady=5)
        method_var = tk.StringVar(value='Cash')
        ttk.Combobox(dialog, textvariable=method_var, 
                    values=['Cash', 'Mobile Money', 'Bank Transfer'], width=27).pack(pady=5)
        
        def process():
            try:
                cursor = self.db.connection.cursor()
                cursor.callproc('sp_process_payment', [
                    app_id,
                    float(amount_entry.get()),
                    method_var.get()
                ])
                self.db.connection.commit()
                cursor.close()
                
                messagebox.showinfo("Success", "Payment processed successfully!")
                dialog.destroy()
                self.show_applications()
                
            except Exception as e:
                messagebox.showerror("Error", str(e))
        
        tk.Button(dialog, text="Process Payment", command=process, 
                 bg='#2ecc71', fg='white').pack(pady=10)
    
    def get_permit_details(self, tree):
        selection = tree.selection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select a permit type first")
            return
        
        permit_id = tree.item(selection[0])['values'][0]
        try:
            cursor = self.db.connection.cursor()
            details = cursor.callfunc('fn_get_permit_details', oracledb.STRING, [permit_id])
            cursor.close()
            
            messagebox.showinfo("Permit Details", details)
            
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    def count_pending_reviews(self, tree):
        selection = tree.selection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select a department first")
            return
        
        dept_id = tree.item(selection[0])['values'][0]
        dept_name = tree.item(selection[0])['values'][1]
        
        try:
            cursor = self.db.connection.cursor()
            count = cursor.callfunc('fn_count_pending_reviews', oracledb.NUMBER, [dept_id])
            cursor.close()
            
            messagebox.showinfo("Pending Reviews", 
                              f"Department: {dept_name}\nPending Reviews: {count}")
            
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    def calc_renewal_fee(self, tree):
        selection = tree.selection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select a license first")
            return
        
        license_id = tree.item(selection[0])['values'][0]
        try:
            cursor = self.db.connection.cursor()
            fee = cursor.callfunc('fn_calculate_renewal_fee', oracledb.NUMBER, [license_id])
            cursor.close()
            
            messagebox.showinfo("Renewal Fee", 
                              f"License ID {license_id}\nRenewal Fee: {fee:,.0f} RWF")
            
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    def complete_review(self, tree):
        selection = tree.selection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select a review step first")
            return
        
        step_id = tree.item(selection[0])['values'][0]
        
        dialog = tk.Toplevel(self.root)
        dialog.title(f"Complete Review Step {step_id}")
        dialog.geometry("350x200")
        
        tk.Label(dialog, text="Decision:").pack(pady=10)
        decision_var = tk.StringVar(value='Approved')
        ttk.Combobox(dialog, textvariable=decision_var, 
                    values=['Approved', 'Rejected', 'Revision Required'], width=30).pack(pady=5)
        
        tk.Label(dialog, text="Comments:").pack(pady=10)
        comments_entry = tk.Entry(dialog, width=40)
        comments_entry.pack(pady=5)
        
        def complete():
            try:
                cursor = self.db.connection.cursor()
                cursor.callproc('sp_complete_review_step', [
                    step_id,
                    decision_var.get(),
                    comments_entry.get()
                ])
                self.db.connection.commit()
                cursor.close()
                
                messagebox.showinfo("Success", "Review step completed!")
                dialog.destroy()
                self.show_review_steps()
                
            except Exception as e:
                messagebox.showerror("Error", str(e))
        
        tk.Button(dialog, text="Complete", command=complete, 
                 bg='#2ecc71', fg='white').pack(pady=10)
    
    def show_about(self):
        about_text = """Permit & License Management System
Version 2.0 - ALL ERRORS FIXED
Developed for Rwanda Government
© 2024 - All rights reserved

Features:
• Complete permit management
• Oracle database integration
• Audit logging system
• Comprehensive reporting
• Bulk operations support
• All errors resolved

Fixed Issues:
✓ DPY-2007 export errors
✓ ORA-20099 business rule errors
✓ ORA-06550 procedure errors
✓ Application number parsing
✓ Weekend operation restrictions"""
        
        messagebox.showinfo("About", about_text)
    
    def on_closing(self):
        if messagebox.askokcancel("Quit", "Do you want to quit?"):
            self.db.disconnect()
            self.root.destroy()


def main():
    root = tk.Tk()
    app = PermitManagementApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()