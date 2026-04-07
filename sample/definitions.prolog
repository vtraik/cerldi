input_event_declaration(login).
input_event_declaration(logout).
input_event_declaration(purchase).
input_event_declaration(crash).
input_event_declaration(downtime_start).
input_event_declaration(downtime_end).

% event definitions
event_def quick_purchase :=
    purchase and tnot logout.

event_def combined_action :=
    login or logout or purchase.

event_def sad_customer :=
    purchase and crash.  

% state definitions
state_def logged_in :=
    login ~> logout.

state_def buying :=
    purchase ~> logout.

state_def active_user :=
    logged_in intersection buying.

state_def interested :=
    logged_in union buying.

state_def downtime :=
    downtime_start ~> downtime_end.

state_def happy_customer :=
    logged_in minus downtime.

