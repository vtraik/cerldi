# Complex Event Recognition (CER) System
This system is a **Complex Event Processing/Recognition (CEP/R) engine** implemented in Prolog. It processes real-time data streams to detect complex events based on predefined logic rules.

---

## 1. Grammar
The system follows the $\mathcal{L}_{\mathcal{DI}}$ language grammar. Formulas are divided into instantaneous events ($\phi^{\bullet}$) and state events with duration ($\phi^{-}$):

```ebnf
ϕ   ::= ϕ• | ϕ-

ϕ•  ::= Pe                                 /* Instantaneous Event */
      | ϕ• and [[tnot]] ϕ•                 /* Conjunction */
      | ϕ• or ϕ•                           /* Disjunction */
      | [start,end] ϕ-                     /* Start/End of a state */

ϕ-  ::= Ps                                 /* State Event */
      | ϕ• ~> ϕ•                           /* Maximal  Intervals Operator */
      | ϕ- [union,intersection,minus] ϕ-   /* Temporal Set Operation  */
```
*Note: Double Square brackets `[[]]` in the grammar denote optional elements while square brackets `[]` choices between operators.*

---

## 2. Semantics
The system assumes discrete time $T = \mathbb{N}$. Interpretation functions determine if a formula is true at a specific time point ($t$) or over an interval $[ts, te]$.

### Instantaneous Semantics ($\mathcal{M}, t \models \phi^{\bullet}$)
* **tnot**:   Standard logical negation at time $t$.
* **and/or**: Standard logical conjunction and disjunction at time $t$.
* **start($\phi^{-}$)**: True at time $t$ if a state $\phi^{-}$ begins at that moment.
* **end($\phi^{-}$)**:   True at time $t$ if a state $\phi^{-}$ terminates at that moment.

### State Semantics ($\mathcal{M}, [ts, te] \models \phi^{-}$)
* **Maximal Intervals Operator ($\phi \sim> \psi$)**: This holds for maximal, non-overlapping intervals. It starts at the earliest time $ts$ where $\phi$ is true and ends at the earliest time $te$ where $\psi \wedge \neg\phi$ becomes true.
* **Union ($\sqcup$)**: Merges overlapping or adjacent intervals where either $\phi$ or $\psi$ is true to form a single maximal interval.
* **Intersection ($\sqcap$)**: Holds only during the specific intervals where both $\phi$ and $\psi$ are simultaneously true.
* **Difference ($\setminus$)**: Holds during the maximal sub-intervals where $\phi$ is true but $\psi$ is false.

---

## 3. Sliding Window Mechanism
To manage finite memory, the system processes the input stream using a sliding window.

* **Parameters**: The user defines a window size $\omega$ and a `step` (the increment between queries).
* **Window Constraints**: The window size must be greater than the step ($\omega > step$).
* **Logic**: 
    * At each query time $t_q$, the engine loads events in the range $(t_q - \omega, t_q]$.
    * Events older than $t_q - \omega$ are purged from the knowledge base.
* **Continuity**: The system stores "open" intervals (states that have started but not yet ended) to ensure correctness when a state spans across multiple windows.

---

## 4. Usage Instructions

### File Formats
1.  **Definitions (`definitions.ldi`)**: Contains `input_event_declaration`, `event_def`, and `state_def`.
2.  **Input (`stream.input`)**: A list of `event(EventName, Time).` facts sorted by time.

### Execution
The system performs a **topological sort** on your definitions to determine the correct processing order (e.g., higher-level events are processed after the lower-level events they depend on).

### Run/Dependencies
##### Dependencies
SWI-Prolog
##### Run
```bash
./run_cerldi
```
Or you can run it yourself with:
```bash
swipl -s cerldi.prolog -g "er(input_file,output_file,definitions_file,Window,Step), halt."
```

### Output
The system writes detected events to an output file in the following formats:
* `event(name(args), time).` 
* `state(name(args), [start, end]).`  

*Note: `inf` is used for states that have not yet ended.*
